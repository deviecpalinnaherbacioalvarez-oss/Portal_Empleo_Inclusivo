const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const {execFileSync} = require('child_process');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base=process.env.PORTAL_URL||'http://localhost:8084/Portal_Empleo_Inclusivo';
const mysql=process.env.MYSQL_EXE||'C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe';
const run=Date.now().toString(), prefix='QA soportes '+run;
const personEmail='qa.sessions.person.'+run+'@example.invalid';
const companyEmail='qa.sessions.company.'+run+'@example.invalid';
const password='Test-'+run;
const output=path.join(__dirname,'../verification');
const checks=[], errors=[];
function pass(s){checks.push(s);console.log('OK: '+s);}
function sql(query){
    return execFileSync(mysql,['--user=incluyelab_app','--host=127.0.0.1','--batch','--skip-column-names','portal_empleo_inclusivo','-e',query],
        {encoding:'utf8',env:{...process.env,MYSQL_PWD:process.env.PORTAL_DB_PASSWORD}}).trim();
}
async function main(){
    assert(process.env.PORTAL_DB_PASSWORD);
    fs.mkdirSync(output,{recursive:true});
    const browser=await chromium.launch({channel:'msedge',headless:true});
    const context=await browser.newContext({viewport:{width:1440,height:1000}});
    const page=await context.newPage();
    page.on('pageerror',e=>errors.push(e.message));
    async function go(route){await page.goto(base+'/'+route);await page.waitForLoadState('networkidle');}
    async function login(email,destination){
        await go('login');
        const before=(await context.cookies()).find(c=>c.name==='JSESSIONID')?.value;
        await page.locator('#correo').fill(email);await page.locator('#contrasena').fill(password);
        await Promise.all([page.waitForURL(base+'/'+destination),page.locator('form button[type=submit]').click()]);
        const cookie=(await context.cookies()).find(c=>c.name==='JSESSIONID');
        assert(cookie && cookie.httpOnly);assert.notEqual(cookie.value,before);
    }
    async function register(email,role){
        await go('registro');
        await page.locator('#rol').selectOption(role);await page.locator('#nombre').fill('QA '+role+' '+run);
        await page.locator('#correo').fill(email);await page.locator('#contrasena').fill(password);
        await Promise.all([page.waitForURL('**/login?registro=ok'),page.locator('form button[type=submit]').click()]);
    }
    async function publish(suffix,supports){
        await go('empresa');
        await page.locator('#titulo').fill(prefix+' '+suffix);
        await page.locator('#modalidad').selectOption('Remoto');
        await page.locator('#ubicacion').fill('Lima');
        await page.locator('#salario').fill('1800');
        await page.locator('#adaptaciones').fill('Texto de prueba: rampas, lector de pantalla, subtitulos. Consultar condiciones.');
        await page.locator('#descripcion').fill('Oferta temporal para comprobar filtros sin inferencias por texto.');
        for(const code of supports)await page.locator('[name=apoyos][value='+code+']').check();
        await Promise.all([page.waitForURL('**/empresa?ok=oferta'),page.locator('.publish-form button[type=submit]').click()]);
        const id=sql("SELECT id_oferta FROM ofertas WHERE titulo='"+prefix+' '+suffix+"'");
        assert.match(id,/^\d+$/);
        assert.deepEqual(sql('SELECT apoyos FROM ofertas WHERE id_oferta='+id).split(',').filter(Boolean).sort(),[...supports].sort());
        return id;
    }
    try {
        for(const route of ['admin','empresa','postulante','admin.jsp','empresa.jsp','postulante.jsp']){
            const response=await context.request.get(base+'/'+route,{maxRedirects:0});
            assert.equal(response.status(),302);
            assert.match(response.headers().location,/\/login\?sesion=/);
            assert.match(response.headers()['cache-control'],/no-store/);
        }
        for(const route of ['admin','oferta','postular'])assert.equal((await context.request.post(base+'/'+route,{form:{}})).status(),403);
        pass('Sin sesion: paneles y JSP protegidos redirigen; escrituras devuelven 403');
        await register(companyEmail,'EMPRESA');await login(companyEmail,'empresa');
        const companyUser=sql("SELECT id_usuario FROM usuarios WHERE correo='"+companyEmail+"'");
        for(const route of ['admin','admin.jsp','postulante','postulante.jsp','login','login.jsp','registro']){
            const response=await context.request.get(base+'/'+route,{maxRedirects:0});
            assert.equal(response.status(),302);assert.equal(response.headers().location,'/Portal_Empleo_Inclusivo/empresa');
        }
        assert.equal((await context.request.post(base+'/postular',{form:{idOferta:'1'}})).status(),403);
        pass('Empresa: redireccion al panel correcto, aislamiento de roles, cookie HttpOnly y sesion renovada');
        const both=await publish('visual auditiva',['lector','subtitulos']);
        const physical=await publish('fisica',['rampas','ascensores']);
        await publish('sin declaracion',[]);
        const count=sql("SELECT COUNT(*) FROM ofertas WHERE titulo LIKE '"+prefix+"%'");
        const invalid=await context.request.post(base+'/oferta',{form:{titulo:prefix+' invalida',modalidad:'Remoto',ubicacion:'Lima',salario:'1800',adaptaciones:'Prueba',descripcion:'Prueba',apoyos:'inventado'}});
        assert((await invalid.text()).includes('Revisa los datos'));
        assert.equal(sql("SELECT COUNT(*) FROM ofertas WHERE titulo LIKE '"+prefix+"%'"),count);
        await go('inicio?q='+encodeURIComponent(prefix));
        assert.equal(await page.locator('.offer-card:visible').count(),3);
        for(const category of ['visual','auditiva','movilidad']){
            await page.locator('[name=adaptacion][value='+category+']').check();
            assert.equal(await page.locator('.offer-card:visible').count(),1);
            assert.equal(await page.locator('.offer-card:visible').getAttribute('data-id'),category==='movilidad'?physical:both);
            await page.locator('[name=adaptacion][value='+category+']').uncheck();
        }
        await page.locator('[name=adaptacion][value=visual]').check();
        await page.locator('[name=adaptacion][value=auditiva]').check();
        assert.equal(await page.locator('.offer-card:visible').count(),1);
        await page.reload();assert.equal(await page.locator('[name=adaptacion]:checked').count(),2);
        await page.locator('[name=adaptacion][value=movilidad]').check();
        assert.equal(await page.locator('.offer-card:visible').count(),0);assert(await page.locator('#empty-results').isVisible());
        await page.locator('#reset-results').click();assert(await page.locator('.offer-card:visible').count()>=3);
        assert.equal(await page.locator('[name=adaptacion]:checked').count(),0);
        assert.equal(await page.locator('[name=adaptacion][value=intelectual], [name=adaptacion][value=neurodivergencia]').count(),0);
        pass('Apoyos guardados en MySQL; filtros exactos, combinacion AND, URL, vacios y limpiar; sin inferir por texto');

        const oldCookie=(await context.cookies()).find(c=>c.name==='JSESSIONID');
        await go('logout');
        assert.match((await context.request.get(base+'/empresa',{maxRedirects:0})).headers().location,/\/login/);
        const replay=await browser.newContext();
        await replay.addCookies([oldCookie]);
        const replayResponse=await replay.request.get(base+'/empresa',{maxRedirects:0});
        assert.equal(replayResponse.status(),302);assert.match(replayResponse.headers().location,/sesion=expirada/);
        await replay.close();
        await login(companyEmail,'empresa');
        sql('UPDATE usuarios SET estado=\'inactivo\' WHERE id_usuario='+companyUser);
        await go('empresa');assert(page.url().includes('sesion=revocada'));
        assert.equal((await context.request.post(base+'/oferta',{form:{}})).status(),403);
        sql('UPDATE usuarios SET estado=\'activo\' WHERE id_usuario='+companyUser);
        await register(personEmail,'POSTULANTE');await login(personEmail,'postulante');
        const person=sql("SELECT id_usuario FROM usuarios WHERE correo='"+personEmail+"'");
        for(const route of ['admin','empresa','admin.jsp','empresa.jsp','login']){
            const response=await context.request.get(base+'/'+route,{maxRedirects:0});
            assert.equal(response.status(),302);assert.equal(response.headers().location,'/Portal_Empleo_Inclusivo/postulante');
        }
        assert.equal((await context.request.post(base+'/oferta',{form:{}})).status(),403);
        sql("UPDATE usuarios SET rol='ADMIN' WHERE id_usuario="+person);
        await go('admin');assert(page.url().includes('sesion=revocada'));
        sql("UPDATE usuarios SET rol='POSTULANTE' WHERE id_usuario="+person);
        pass('Cerrar sesion invalida la cookie; cuenta inactiva y cambio de rol revocan acceso existente');

        await go('login');await page.locator('#correo').fill('admin@incluyelab.pe');await page.locator('#contrasena').fill(process.env.PORTAL_ADMIN_PASSWORD||'123456');
        await Promise.all([page.waitForURL(base+'/admin'),page.locator('form button[type=submit]').click()]);
        await go('admin?entidad=ofertas&accion=editar&id='+both);
        assert(await page.locator('[name=apoyos][value=lector]').isChecked());
        assert(await page.locator('[name=apoyos][value=subtitulos]').isChecked());
        for(const width of [390,768,1440]){
            await page.setViewportSize({width,height:950});
            assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
            await page.screenshot({path:path.join(output,'supports-form-'+width+'.png')});
        }
        const all=await page.locator('[name=apoyos]').evaluateAll(nodes=>nodes.map(n=>n.value));
        for(const code of all)await page.locator('[name=apoyos][value='+code+']').check();
        await Promise.all([page.waitForURL(base+'/admin#ofertas'),page.locator('.admin-form button[type=submit]').click()]);
        assert.deepEqual(sql('SELECT apoyos FROM ofertas WHERE id_oferta='+both).split(',').sort(),all.sort());
        await go('inicio?q='+encodeURIComponent(prefix)+'&adaptacion=movilidad&adaptacion=visual&adaptacion=auditiva&adaptacion=flexible&adaptacion=pausas');
        assert.equal(await page.locator('.offer-card:visible').count(),1);
        await go('admin?entidad=ofertas&accion=editar&id='+both);
        for(const code of all)await page.locator('[name=apoyos][value='+code+']').uncheck();
        await Promise.all([page.waitForURL(base+'/admin#ofertas'),page.locator('.admin-form button[type=submit]').click()]);
        assert.equal(sql('SELECT apoyos FROM ofertas WHERE id_oferta='+both),'');
        await go('inicio?q='+encodeURIComponent(prefix)+'&adaptacion=visual');
        assert.equal(await page.locator('.offer-card:visible').count(),0);
        pass('Administrador edita los 13 apoyos, puede quitarlos; filtros reflejan cambios tras recargar');
        for(const width of [390,768,1440]){
            await page.setViewportSize({width,height:950});await go('inicio#ofertas');
            assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
            await page.screenshot({path:path.join(output,'supports-sidebar-'+width+'.png')});
        }
        await page.setViewportSize({width:390,height:950});
        for(const preference of ['contrast','font','large'])await page.locator('[data-preference='+preference+']').click();
        assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
        await page.screenshot({path:path.join(output,'supports-accessible.png')});
        assert.deepEqual(errors,[]);
        pass('Sidebar y formularios adaptables; accesibilidad conservada; sin errores JavaScript');
    } finally {
        await page.screenshot({path:path.join(output,'sessions-last-state.png')}).catch(()=>{});
        await browser.close();
        sql("START TRANSACTION; DELETE o FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE e FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE FROM usuarios WHERE correo IN ('"+personEmail+"','"+companyEmail+"'); COMMIT;");
        fs.writeFileSync(path.join(output,'sessions-supports-results.json'),JSON.stringify({date:new Date().toISOString(),checks,errors},null,2));
    }
}
main().catch(e=>{console.error(e);process.exitCode=1;});
