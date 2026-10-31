const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const {execFileSync} = require('child_process');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.PORTAL_URL || 'http://localhost:8084/Portal_Empleo_Inclusivo';
const output = path.join(__dirname, '../verification');
const mysql = 'C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe';
const run = Date.now().toString();
const ids = [], checks = [], errors = [];
function sql(query) {
    return execFileSync(mysql, ['--user=incluyelab_app','--host=127.0.0.1','--batch','--skip-column-names','portal_empleo_inclusivo','-e',query],
        {encoding:'utf8',env:{...process.env,MYSQL_PWD:process.env.PORTAL_DB_PASSWORD}}).trim();
}
function pass(message) { checks.push(message); console.log('OK: '+message); }
async function login(context, email, password) {
    return context.request.post(base+'/login',{form:{correo:email,contrasena:password},maxRedirects:0});
}
(async()=>{
    assert(process.env.PORTAL_DB_PASSWORD);
    fs.mkdirSync(output,{recursive:true});
    const before = sql('SELECT id_usuario,contrasena FROM usuarios ORDER BY id_usuario');
    const counts = sql('SELECT (SELECT COUNT(*) FROM empresas),(SELECT COUNT(*) FROM ofertas)');
    const browser = await chromium.launch({channel:'msedge',headless:true});
    try {
        const anonymous = await browser.newContext();
        assert.match((await anonymous.request.get(base+'/perfil',{maxRedirects:0})).headers().location,/login/);
        assert.equal((await anonymous.request.post(base+'/perfil',{form:{}})).status(),403);
        assert.equal((await anonymous.request.get(base+'/WEB-INF/perfil.jsp')).status(),404);
        await anonymous.close();
        pass('Perfil protegido: acceso anonimo y JSP directo bloqueados');
        for (const role of ['ADMIN','EMPRESA','POSTULANTE']) {
            const email = 'password.'+role.toLowerCase()+'.'+run+'@example.invalid';
            const oldPassword = 'Anterior-'+run;
            const newPassword = 'Nueva-'+run+'-A ';
            const id = sql("INSERT INTO usuarios(nombre,correo,contrasena,rol,estado) VALUES('Cuenta temporal de verificacion','"+email+"','"+oldPassword+"','"+role+"','activo'); SELECT LAST_INSERT_ID();");
            assert.match(id,/^\d+$/); ids.push(id);
            const context = await browser.newContext({viewport:{width:1440,height:1000}});
            const other = await browser.newContext();
            assert.equal((await login(context,email,oldPassword)).status(),302);
            assert.equal((await login(other,email,oldPassword)).status(),302);
            const page = await context.newPage();page.on('pageerror',e=>errors.push(e.message));
            assert.equal((await page.goto(base+'/perfil')).status(),200);
            await page.waitForLoadState('networkidle');
            const csrf = await page.locator('[name=csrf]').inputValue();
            assert.equal(await page.locator('#actual').getAttribute('type'),'password');
            await page.locator('[data-toggle-password=actual]').click();
            assert.equal(await page.locator('#actual').getAttribute('type'),'text');
            await page.locator('[data-toggle-password=actual]').click();
            assert.equal(await page.locator('#actual').getAttribute('type'),'password');
            const submit = (values) => context.request.post(base+'/perfil',{form:{csrf,actual:oldPassword,nueva:newPassword,confirmar:newPassword,...values},maxRedirects:0});
            assert.equal((await submit({csrf:'incorrecto'})).status(),403);
            for (const values of [
                {actual:'incorrecta'}, {confirmar:'diferente'}, {nueva:'123',confirmar:'123'},
                {nueva:'a'.repeat(101),confirmar:'a'.repeat(101)},
                {nueva:oldPassword,confirmar:oldPassword}, {nueva:'        ',confirmar:'        '}
            ]) {
                const result = await submit(values);
                assert.equal(result.status(),400);
                assert(!(await result.text()).includes('value="'+oldPassword+'"'));
                assert.equal(sql('SELECT contrasena FROM usuarios WHERE id_usuario='+id),oldPassword);
            }
            if (role === 'POSTULANTE') {
                for (const width of [1440,1024,850,768,390]) {
                    await page.setViewportSize({width,height:1000});
                    assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Overflow '+width);
                    await page.screenshot({path:path.join(output,'perfil-'+width+'.png'),fullPage:true});
                }
                await page.locator('.menu-toggle').click();
                assert(await page.getByRole('link',{name:'Mi perfil',exact:true}).isVisible());
                await page.locator('[data-preference=large]').click();
                await page.locator('[data-preference=contrast]').click();
                assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
                await page.screenshot({path:path.join(output,'perfil-accesible.png'),fullPage:true});
                await page.locator('.menu-toggle').click();
                await page.locator('#actual').fill(oldPassword);
                await page.locator('#nueva').fill(newPassword);
                await page.locator('#confirmar').fill(newPassword);
                await page.getByRole('button',{name:'Guardar contraseña'}).click();
                await page.waitForURL('**/login?clave=actualizada');
                assert(await page.locator('.alert-success').isVisible());
            } else {
                const result = await submit({idUsuario:'1',rol:'ADMIN'});
                assert.equal(result.status(),302);
                assert.match(result.headers().location,/clave=actualizada/);
            }
            const stored = sql('SELECT contrasena FROM usuarios WHERE id_usuario='+id);
            assert.match(stored,/^pbkdf2\$600000\$/);assert(stored.length<=100);
            assert.notEqual(stored,newPassword);
            assert.match((await context.request.get(base+'/perfil',{maxRedirects:0})).headers().location,/login/);
            assert.match((await other.request.get(base+'/perfil',{maxRedirects:0})).headers().location,/sesion=revocada/);
            assert.equal((await login(context,email,oldPassword)).status(),200);
            assert.equal((await login(context,email,newPassword.toLowerCase())).status(),200);
            assert.equal((await login(context,email,newPassword.trim())).status(),200);
            assert.equal((await login(context,email,newPassword)).status(),302);
            assert.equal((await context.request.get(base+'/perfil')).status(),200);
            await context.close();await other.close();
            pass(role+': cambio persistente, validaciones, hash, aislamiento por cuenta y revocacion de sesiones');
        }
        // Registration and admin editing use the same password storage format.
        const register = await browser.newContext();
        const email = 'password.register.'+run+'@example.invalid';
        const registration = await register.request.post(base+'/registro',{form:{nombre:'Cuenta temporal registro',correo:email,contrasena:'Registro-'+run,rol:'POSTULANTE'},maxRedirects:0});
        const registered = sql("SELECT id_usuario FROM usuarios WHERE correo='"+email+"'");
        if (/^\d+$/.test(registered)) ids.push(registered);
        assert.equal(registration.status(),302);assert.match(registered,/^\d+$/);
        assert.match(sql('SELECT contrasena FROM usuarios WHERE id_usuario='+registered),/^pbkdf2\$/);
        assert.equal((await login(register,email,'Registro-'+run)).status(),302);
        await register.close();
        const admin = await browser.newContext();
        assert.equal((await login(admin,'password.admin.'+run+'@example.invalid','Nueva-'+run+'-A ')).status(),302);
        const page = await admin.newPage();
        await page.goto(base+'/admin?entidad=usuarios&accion=editar&id='+registered);
        const hash = sql('SELECT contrasena FROM usuarios WHERE id_usuario='+registered);
        await page.locator('.admin-form button[type=submit]').click();
        await page.waitForURL('**/admin#usuarios');
        assert.equal(sql('SELECT contrasena FROM usuarios WHERE id_usuario='+registered),hash);
        await page.goto(base+'/admin?entidad=usuarios&accion=editar&id='+registered);
        await page.locator('[name=contrasena]').fill('AdminCambio-'+run);
        await page.locator('.admin-form button[type=submit]').click();
        await page.waitForURL('**/admin#usuarios');
        const candidate = await browser.newContext();
        assert.equal((await login(candidate,email,'AdminCambio-'+run)).status(),302);
        await candidate.close();await admin.close();
        pass('Registro y edicion administrativa compatibles con hashes; clave vacia conserva la anterior');
        assert.deepEqual(errors,[]);
    } finally {
        await browser.close();
        if(ids.length) sql('DELETE FROM usuarios WHERE id_usuario IN ('+ids.join(',')+')');
        assert.equal(sql('SELECT id_usuario,contrasena FROM usuarios ORDER BY id_usuario'),before,'Se modifico una cuenta original');
        assert.equal(sql('SELECT (SELECT COUNT(*) FROM empresas),(SELECT COUNT(*) FROM ofertas)'),counts);
    }
    pass('Sin cambios a cuentas originales, empresas u ofertas; cuentas temporales eliminadas');
    fs.writeFileSync(path.join(output,'password-results.json'),JSON.stringify({date:new Date().toISOString(),checks,errors},null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
