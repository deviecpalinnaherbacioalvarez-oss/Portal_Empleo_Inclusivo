const path = require('path');
const fs = require('fs');
const assert = require('node:assert/strict');
const { execFileSync } = require('child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.PORTAL_URL || 'http://localhost:8084/Portal_Empleo_Inclusivo';
const output = path.join(__dirname, '../verification');
fs.mkdirSync(output, { recursive: true });
const mysql = process.env.MYSQL_EXE || 'C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe';
const run = Date.now().toString();
const companyEmail = 'qa.empresa.' + run + '@example.invalid';
const personEmail = 'qa.postulante.' + run + '@example.invalid';
const password = 'Prueba-' + run;
const testTitle = 'QA accesibilidad ' + run;
const report = [];
function sql(query) {
    return execFileSync(mysql, ['--user=incluyelab_app', '--host=127.0.0.1', '--batch', '--skip-column-names', 'portal_empleo_inclusivo', '-e', query], {
        encoding: 'utf8', env: { ...process.env, MYSQL_PWD: process.env.PORTAL_DB_PASSWORD }
    }).trim();
}
function pass(message) { report.push(message); console.log('OK: ' + message); }
async function main() {
    const browser = await chromium.launch({ channel: 'msedge', headless: true });
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', err => errors.push(err.message));
    page.on('response', res => { if (res.url().startsWith(base) && res.status() >= 400) errors.push(res.status() + ': ' + res.url()); });
    async function go(route = '') { await page.goto(base + '/' + route); await page.waitForLoadState('networkidle'); }
    async function login(email, passcode) {
        await go('login'); await page.locator('#correo').fill(email); await page.locator('#contrasena').fill(passcode);
        await Promise.all([page.waitForURL(url => !url.pathname.endsWith('/login')), page.locator('form button[type=submit]').click()]);
    }
    async function register(email, role, name) {
        await go('registro'); await page.locator('#rol').selectOption(role); await page.locator('#nombre').fill(name); await page.locator('#correo').fill(email); await page.locator('#contrasena').fill(password);
        await Promise.all([page.waitForURL('**/login?registro=ok'), page.locator('form button[type=submit]').click()]);
        assert.equal(await page.locator('.notice').count(), 1);
    }
    try {
        await go();
        const total = await page.locator('.offer-card').count(); assert(total > 0, 'Ofertas desde MySQL');
        await page.locator('#empresas').scrollIntoViewIfNeeded();
        const broken = await page.locator('img').evaluateAll(async images => { await Promise.all(images.map(i => i.decode().catch(() => {}))); return images.filter(i => !i.naturalWidth).map(i => i.src); });
        assert.deepEqual(broken, []); assert.equal(await page.locator('.company-tile').count(), 23);
        assert.equal(await page.locator('.offer-grid').evaluate(el => getComputedStyle(el).display), 'grid');
        assert(!(await page.locator('body').innerText()).includes('acompaÃ'));
        await page.evaluate(() => window.scrollTo(0,0)); await page.screenshot({path:path.join(output,'desktop.png')});
        pass('CSS, fuentes, iconos y 23 logos locales cargan; ofertas provenientes de MySQL');
        await page.locator('[name=modalidad][value=Remoto]').check();
        assert(await page.locator('.offer-card:visible').count() > 0);
        for (const mode of await page.locator('.offer-card:visible').evaluateAll(c => c.map(x => x.dataset.mode))) assert.match(mode, /remoto/i);
        await page.locator('#clear-filters').click();
        await page.locator('#company-filter').selectOption('BCP'); assert(await page.locator('.offer-card:visible').count() > 0);
        await page.locator('#clear-filters').click();
        await page.locator('#q').fill('inexistente-' + run); await page.locator('#job-search button').click(); assert(await page.locator('#empty-results').isVisible());
        await page.locator('#reset-results').click(); assert.equal(await page.locator('.offer-card:visible').count(), total);
        await page.locator('[name=adaptacion][value=visual]').check(); assert(await page.locator('.offer-card:visible').count() > 0);
        await page.reload(); assert(await page.locator('[name=adaptacion][value=visual]').isChecked()); await page.locator('#clear-filters').click();
        await page.locator('#sort').selectOption('salary'); const salaries = await page.locator('.offer-card').evaluateAll(c => c.map(x => +x.dataset.salary)); assert.deepEqual(salaries,[...salaries].sort((a,b)=>b-a));
        pass('Búsqueda, modalidad, adaptaciones, empresa, orden y restauración de filtros');
        await page.locator('[data-save]').first().click(); await page.reload(); assert.equal(await page.locator('#saved-count').textContent(),'1');
        await page.locator('.saved-filter').click(); assert.equal(await page.locator('.offer-card:visible').count(),1);
        await page.locator('.offer-card:visible [data-save]').click(); assert(await page.locator('#empty-results').isVisible());
        await page.locator('#clear-filters').click(); pass('Guardadas persistentes en este navegador y eliminación');
        const selectedTitle = await page.locator('.job-title').nth(1).innerText(); await page.locator('.job-title').nth(1).click(); assert.equal(await page.locator('#detail-title').innerText(), selectedTitle);
        await page.keyboard.press('Escape'); assert(!(await page.locator('#job-dialog').isVisible()));
        await page.locator('.job-title').first().click(); await page.locator('[data-close-dialog]').click(); pass('Detalle correcto de cada oferta, cierre por botón y Escape');
        for (const key of ['contrast','font','large']) await page.locator('[data-preference='+key+']').click();
        await go('login'); assert(await page.locator('html').evaluate(el => el.classList.contains('high-contrast') && el.classList.contains('readable-font') && el.classList.contains('large-text')));
        await page.locator('#contrasena').fill('test'); await page.locator('[data-toggle-password]').click(); assert.equal(await page.locator('#contrasena').getAttribute('type'),'text');
        await page.screenshot({path:path.join(output,'high-contrast-login.png')});
        for (const key of ['contrast','font','large']) await page.locator('[data-preference='+key+']').click(); pass('Accesibilidad persistente entre pantallas y mostrar/ocultar contraseña');
        for (const width of [390,768,1440]) {
            await page.setViewportSize({width,height:900}); await go();
            assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1), 'Desborde horizontal '+width);
            if (width === 390) { await page.locator('.menu-toggle').click(); assert(await page.locator('#main-nav').isVisible()); await page.locator('.menu-toggle').click(); }
            await page.screenshot({path:path.join(output,'viewport-'+width+'.png')});
        }
        await page.setViewportSize({width:390,height:844}); await page.locator('[data-preference=large]').click(); assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1),'Desborde móvil con texto grande');
        await page.locator('[data-preference=large]').click(); await page.setViewportSize({width:1440,height:1000}); pass('Responsive 390/768/1440px, menú móvil y texto ampliado sin desbordes');
        if (process.env.PORTAL_DB_PASSWORD) {
            await register(companyEmail,'EMPRESA','Empresa QA '+run); await login(companyEmail,password); assert(page.url().includes('/empresa'));
            await page.locator('#titulo').fill(testTitle); await page.locator('#modalidad').selectOption('Remoto'); await page.locator('#ubicacion').fill('Lima, Perú');
            await page.locator('#salario').fill('2400'); await page.locator('#adaptaciones').fill('Lector de pantalla y horario flexible'); await page.locator('#descripcion').fill('Vacante temporal de verificación de publicación y postulación.');
            await Promise.all([page.waitForURL('**/empresa?ok=oferta'),page.locator('.publish-form button[type=submit]').click()]);
            const offerId = sql("SELECT o.id_oferta FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"' AND o.titulo='"+testTitle+"'"); assert.match(offerId,/^[0-9]+$/);
            await page.screenshot({path:path.join(output,'empresa.png')}); await go('logout'); await register(personEmail,'POSTULANTE','Postulante QA '+run);
            await go('inicio?oferta='+offerId); await page.locator('#job-dialog a.btn.magenta').click(); await page.locator('#correo').fill(personEmail); await page.locator('#contrasena').fill(password);
            await Promise.all([page.waitForURL('**/inicio?oferta='+offerId+'#ofertas'),page.locator('form button[type=submit]').click()]);
            await page.locator('#job-dialog form button[type=submit]').click(); await page.waitForURL('**/postulante?ok=postulacion');
            assert(await page.locator('.application-row').filter({hasText:testTitle}).count()===1);
            assert.equal(sql("SELECT COUNT(*) FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.correo='"+personEmail+"' AND p.id_oferta="+offerId),'1');
            await go('inicio?oferta='+offerId); await page.locator('#job-dialog form button[type=submit]').click(); await page.waitForURL('**/postulante'); assert(await page.locator('.error').isVisible());
            assert.equal(sql("SELECT COUNT(*) FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.correo='"+personEmail+"' AND p.id_oferta="+offerId),'1');
            await page.screenshot({path:path.join(output,'postulante.png')}); pass('Registro y login empresa/postulante, publicación y postulación confirmados con SELECT en MySQL; repetición bloqueada');
            await go('logout'); await login('admin@incluyelab.pe',process.env.PORTAL_ADMIN_PASSWORD || '123456'); assert(page.url().includes('/admin'));
            await page.locator('[data-table-search=users-table]').fill(personEmail); assert.equal(await page.locator('#users-table tbody tr:visible').count(),1);
            await page.locator('[data-table-search=users-table]').fill('sin-resultados-'+run); assert(await page.locator('#users-table .table-empty').isVisible());
            await page.locator('[data-table-search=users-table]').fill(''); await page.screenshot({path:path.join(output,'admin.png')}); pass('Ingreso administrativo y filtros de tablas');
        }
        assert.deepEqual(errors,[]); pass('Sin errores JavaScript ni recursos HTTP fallidos');
    } finally {
        await page.screenshot({path:path.join(output,'last-state.png')}).catch(()=>{});
        await browser.close();
        if (process.env.PORTAL_DB_PASSWORD) {
            sql("START TRANSACTION; DELETE p FROM postulaciones p JOIN usuarios u ON p.id_usuario=u.id_usuario WHERE u.correo='"+personEmail+"'; DELETE o FROM ofertas o JOIN empresas e ON o.id_empresa=e.id_empresa JOIN usuarios u ON e.id_usuario=u.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE e FROM empresas e JOIN usuarios u ON e.id_usuario=u.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE FROM usuarios WHERE correo IN ('"+companyEmail+"','"+personEmail+"'); COMMIT;"); pass('Solo los registros temporales de esta prueba fueron eliminados');
        }
        fs.writeFileSync(path.join(output,'results.json'),JSON.stringify({date:new Date().toISOString(),checks:report,errors},null,2));
    }
}
main().catch(error=>{console.error(error);process.exitCode=1;});
