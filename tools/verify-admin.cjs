const fs = require('fs');
const path = require('path');
const assert = require('node:assert/strict');
const { execFileSync } = require('child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.PORTAL_URL || 'http://localhost:8084/Portal_Empleo_Inclusivo';
const mysql = process.env.MYSQL_EXE || 'C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe';
const run = Date.now().toString();
const personEmail = 'qa.crud.person.' + run + '@example.invalid';
const companyEmail = 'qa.crud.company.' + run + '@example.invalid';
const password = 'QA-' + run;
const title = 'CRUD oferta ' + run;
const output = path.join(__dirname, '../verification');
const checks = [], errors = [];
fs.mkdirSync(output, { recursive: true });
function sql(query) {
    return execFileSync(mysql, ['--user=incluyelab_app','--host=127.0.0.1','--batch','--skip-column-names','portal_empleo_inclusivo','-e',query],
        { encoding:'utf8', env:{...process.env, MYSQL_PWD:process.env.PORTAL_DB_PASSWORD} }).trim();
}
function pass(message) { checks.push(message); console.log('OK: ' + message); }
async function main() {
    assert(process.env.PORTAL_DB_PASSWORD, 'Se requiere PORTAL_DB_PASSWORD para verificar persistencia.');
    const browser = await chromium.launch({channel:'msedge',headless:true});
    const context = await browser.newContext({viewport:{width:1440,height:1000}});
    const page = await context.newPage();
    page.on('pageerror', e => errors.push(e.message));
    page.on('response', r => { if(r.url().startsWith(base) && r.status() >= 400) errors.push(r.status()+': '+r.url()); });
    async function go(route) { await page.goto(base+'/'+route); await page.waitForLoadState('networkidle'); }
    async function fill(values) {
        for(const [name,value] of Object.entries(values)) {
            const el=page.locator('[name="'+name+'"]:not([type=hidden])');
            if(await el.evaluate(e=>e.tagName)==='SELECT') await el.selectOption(value);
            else await el.fill(value);
        }
    }
    async function save(entity) {
        await Promise.all([page.waitForURL(base+'/admin#'+entity),page.locator('.admin-form button[type=submit]').click()]);
        assert(await page.locator('.notice').isVisible());
    }
    async function remove(entity,id) {
        await go('admin?entidad='+entity+'&accion=eliminar&id='+id);
        assert.match(await page.locator('h1').innerText(),/^Eliminar/);
        await Promise.all([page.waitForURL(base+'/admin#'+entity),page.locator('form button[type=submit]').click()]);
    }
    try {
        await go('login'); await fill({correo:'admin@incluyelab.pe',contrasena:process.env.PORTAL_ADMIN_PASSWORD||'123456'});
        await Promise.all([page.waitForURL(base+'/admin'),page.locator('form button[type=submit]').click()]);
        assert.equal(await page.evaluate(()=>bootstrap.Alert.VERSION),'5.3.8');
        assert.equal(await page.locator('.table-responsive').count(),4);
        await page.locator('#usuarios a[href*="accion=nuevo"]').click();
        const csrf=await page.locator('[name=csrf]').inputValue();
        await fill({nombre:'CRUD postulante '+run,correo:personEmail,contrasena:password,rol:'POSTULANTE',estado:'activo'});
        await save('usuarios');
        const person=sql("SELECT id_usuario FROM usuarios WHERE correo='"+personEmail+"'");assert.match(person,/^[0-9]+$/);
        const originalHash=sql('SELECT contrasena FROM usuarios WHERE id_usuario='+person);
        assert.match(originalHash,/^pbkdf2\$/);
        await page.locator('.notice [data-bs-dismiss=alert]').click();await page.locator('.notice').waitFor({state:'detached'});
        await go('admin?entidad=usuarios&accion=editar&id='+person);
        await fill({nombre:'CRUD postulante editado '+run}); await save('usuarios');
        assert.equal(sql('SELECT nombre FROM usuarios WHERE id_usuario='+person),'CRUD postulante editado '+run);
        assert.equal(sql('SELECT contrasena FROM usuarios WHERE id_usuario='+person),originalHash);
        pass('Usuarios: crear y editar guardan en MySQL; clave vacia conserva la anterior; alerta Bootstrap funcional');

        await page.locator('#empresas a[href*="accion=nuevo"]').click();
        await fill({razonSocial:'CRUD empresa '+run,ruc:'20123456789',sector:'Tecnologia',selloInclusivo:'Pendiente',correo:companyEmail,contrasena:password});
        await save('empresas');
        const company=sql("SELECT e.id_empresa FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"'");
        const companyUser=sql("SELECT id_usuario FROM usuarios WHERE correo='"+companyEmail+"'");
        assert.match(company,/^[0-9]+$/);assert.equal(sql('SELECT rol FROM usuarios WHERE id_usuario='+companyUser),'EMPRESA');
        await go('admin?entidad=empresas&accion=editar&id='+company);
        await fill({razonSocial:'CRUD empresa editada '+run,sector:'Servicios accesibles',selloInclusivo:'En revision'});await save('empresas');
        assert.equal(sql('SELECT sector FROM empresas WHERE id_empresa='+company),'Servicios accesibles');
        pass('Empresas: alta crea cuenta vinculada y edicion conserva la cuenta existente');

        await page.locator('#ofertas a[href*="accion=nuevo"]').click();
        await fill({idEmpresa:company,titulo:title,modalidad:'Remoto',ubicacion:'Lima, Peru',salario:'2350.50',estado:'activa',adaptaciones:'Lector de pantalla',descripcion:'Oferta temporal de pruebas.'});
        await save('ofertas');
        const offer=sql("SELECT id_oferta FROM ofertas WHERE id_empresa="+company+" AND titulo='"+title+"'");
        assert.match(offer,/^[0-9]+$/);
        await go('admin?entidad=ofertas&accion=editar&id='+offer); await fill({salario:'2800.25',descripcion:'Descripcion editada por el administrador.'});await save('ofertas');
        assert.equal(sql('SELECT salario FROM ofertas WHERE id_oferta='+offer),'2800.25');
        await go('inicio?q='+encodeURIComponent(title));assert.equal(await page.locator('.offer-card:visible').count(),1);
        pass('Ofertas: crear y editar reflejan los cambios en MySQL y en el portal publico');

        await go('admin');await page.locator('#postulaciones a[href*="accion=nuevo"]').click();
        await fill({idUsuario:person,idOferta:offer,estado:'pendiente'});await save('postulaciones');
        const application=sql('SELECT id_postulacion FROM postulaciones WHERE id_usuario='+person+' AND id_oferta='+offer);
        assert.match(application,/^[0-9]+$/);
        await go('admin?entidad=postulaciones&accion=editar&id='+application);await fill({estado:'aceptado'});await save('postulaciones');
        assert.equal(sql('SELECT estado FROM postulaciones WHERE id_postulacion='+application),'aceptado');
        const candidateContext=await browser.newContext();const candidate=await candidateContext.newPage();
        await candidate.goto(base+'/login');await candidate.locator('#correo').fill(personEmail);await candidate.locator('#contrasena').fill(password);
        await Promise.all([candidate.waitForURL(base+'/postulante'),candidate.locator('form button[type=submit]').click()]);
        assert(await candidate.locator('.application-row').filter({hasText:title}).getByText('aceptado',{exact:true}).isVisible());
        assert.equal((await candidateContext.request.post(base+'/admin',{form:{csrf,accion:'eliminar',entidad:'ofertas',id:offer}})).status(),403);
        await candidateContext.close();
        pass('Postulaciones: crear y cambiar estado persiste y se muestra al postulante; este no tiene permisos de CRUD');

        await go('admin?entidad=ofertas&accion=eliminar&id='+offer);
        assert.equal(sql('SELECT COUNT(*) FROM ofertas WHERE id_oferta='+offer),'1');
        await page.getByRole('link',{name:'Cancelar',exact:true}).click();
        assert.equal(sql('SELECT COUNT(*) FROM ofertas WHERE id_oferta='+offer),'1');
        for(const [entity,id,table,key] of [['ofertas',offer,'ofertas','id_oferta'],['usuarios',person,'usuarios','id_usuario'],['empresas',company,'empresas','id_empresa']]) {
            await go('admin?entidad='+entity+'&accion=eliminar&id='+id);
            await page.locator('form button[type=submit]').click();await page.waitForLoadState('networkidle');
            assert.match(await page.locator('.error').innerText(),/registros relacionados/);
            assert.equal(sql('SELECT COUNT(*) FROM '+table+' WHERE '+key+'='+id),'1');
        }
        pass('Eliminar pide confirmacion; cancelar no modifica datos; dependencias bloquean eliminaciones destructivas');

        const request=context.request;
        assert.equal((await request.post(base+'/admin',{form:{accion:'eliminar',entidad:'usuarios',id:person}})).status(),403);
        assert.equal((await request.post(base+'/admin',{form:{csrf,accion:'eliminar',entidad:'usuarios',id:'-1'}})).status(),400);
        assert.equal((await request.get(base+'/admin?entidad=usuarios&accion=editar&id=2147483647')).status(),404);
        const negative=await request.post(base+'/admin',{form:{csrf,accion:'guardar',entidad:'ofertas',id:offer,idEmpresa:company,titulo:title,modalidad:'Remoto',ubicacion:'Lima',salario:'-5',estado:'activa',adaptaciones:'Prueba',descripcion:'Prueba'}});
        assert((await negative.text()).includes('Ingresa un salario'));assert.equal(sql('SELECT salario FROM ofertas WHERE id_oferta='+offer),'2800.25');
        const duplicate=await request.post(base+'/admin',{form:{csrf,accion:'guardar',entidad:'usuarios',id:'0',nombre:'No crear',correo:personEmail,contrasena:password,rol:'POSTULANTE',estado:'activo'}});
        assert((await duplicate.text()).includes('correo ya esta registrado'));assert.equal(sql("SELECT COUNT(*) FROM usuarios WHERE correo='"+personEmail+"'"),'1');
        const invalidRole=await request.post(base+'/admin',{form:{csrf,accion:'guardar',entidad:'usuarios',id:person,nombre:'No cambiar',correo:personEmail,contrasena:'',rol:'INVALIDO',estado:'activo'}});
        assert((await invalidRole.text()).includes('opcion valida'));assert.equal(sql('SELECT rol FROM usuarios WHERE id_usuario='+person),'POSTULANTE');
        const duplicateApplication=await request.post(base+'/admin',{form:{csrf,accion:'guardar',entidad:'postulaciones',id:'0',idUsuario:person,idOferta:offer,estado:'pendiente'}});
        assert((await duplicateApplication.text()).includes('ya postulo'));assert.equal(sql('SELECT COUNT(*) FROM postulaciones WHERE id_usuario='+person+' AND id_oferta='+offer),'1');
        const actor=sql("SELECT id_usuario FROM usuarios WHERE correo='admin@incluyelab.pe'");
        const own=await request.post(base+'/admin',{form:{csrf,accion:'eliminar',entidad:'usuarios',id:actor}});
        assert((await own.text()).includes('propia cuenta'));assert.equal(sql('SELECT estado FROM usuarios WHERE id_usuario='+actor),'activo');
        await go('admin?entidad=usuarios&accion=editar&id='+actor);await fill({estado:'inactivo'});await page.locator('.admin-form button[type=submit]').click();await page.waitForLoadState('networkidle');
        assert.match(await page.locator('.error').innerText(),/propia cuenta/);assert.equal(sql('SELECT estado FROM usuarios WHERE id_usuario='+actor),'activo');
        const anonymous=await browser.newContext();
        assert.equal((await anonymous.request.post(base+'/admin',{form:{csrf,accion:'eliminar',entidad:'usuarios',id:person}})).status(),403);
        await anonymous.close();
        pass('Servidor valida CSRF, roles, salario, correos, duplicados, IDs y protege la propia cuenta administrativa');

        for(const width of [390,768,1440]) {
            await page.setViewportSize({width,height:950});await go('admin');
            assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Desborde en panel '+width);
            await page.screenshot({path:path.join(output,'admin-bootstrap-'+width+'.png')});
            await go('admin?entidad=ofertas&accion=editar&id='+offer);
            assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Desborde en formulario '+width);
            await page.screenshot({path:path.join(output,'admin-form-'+width+'.png')});
        }
        for(const preference of ['contrast','large'])await page.locator('[data-preference='+preference+']').click();
        await page.setViewportSize({width:390,height:950});
        assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Desborde con accesibilidad');
        await page.screenshot({path:path.join(output,'admin-form-accessible.png')});
        for(const preference of ['contrast','large'])await page.locator('[data-preference='+preference+']').click();
        pass('Panel y formularios Bootstrap adaptables a 390/768/1440 px y accesibilidad conservada');

        await remove('postulaciones',application);assert.equal(sql('SELECT COUNT(*) FROM postulaciones WHERE id_postulacion='+application),'0');
        await remove('ofertas',offer);assert.equal(sql('SELECT COUNT(*) FROM ofertas WHERE id_oferta='+offer),'0');
        await remove('empresas',company);assert.equal(sql('SELECT COUNT(*) FROM empresas WHERE id_empresa='+company),'0');
        assert.equal(sql('SELECT COUNT(*) FROM usuarios WHERE id_usuario='+companyUser),'1');
        await remove('usuarios',person);await remove('usuarios',companyUser);
        assert.equal(sql("SELECT COUNT(*) FROM usuarios WHERE correo IN ('"+personEmail+"','"+companyEmail+"')"),'0');
        pass('Eliminar funciona para las cuatro entidades sin dependencias; persistencia confirmada con SELECT');
        assert.deepEqual(errors,[]);pass('Sin errores JavaScript ni recursos HTTP fallidos');
    } finally {
        await page.screenshot({path:path.join(output,'admin-last-state.png')}).catch(()=>{});
        await browser.close();
        sql("START TRANSACTION; DELETE p FROM postulaciones p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.correo='"+personEmail+"'; DELETE o FROM ofertas o JOIN empresas e ON e.id_empresa=o.id_empresa JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE e FROM empresas e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.correo='"+companyEmail+"'; DELETE FROM usuarios WHERE correo IN ('"+personEmail+"','"+companyEmail+"'); COMMIT;");
        fs.writeFileSync(path.join(output,'admin-results.json'),JSON.stringify({date:new Date().toISOString(),checks,errors},null,2));
    }
}
main().catch(e=>{console.error(e);process.exitCode=1;});
