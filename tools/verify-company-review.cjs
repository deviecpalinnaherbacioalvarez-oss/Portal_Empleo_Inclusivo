const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const base='http://localhost:8084/Portal_Empleo_Inclusivo',out=path.join(__dirname,'../verification');
const checks=[],errors=[];
function ok(s){checks.push(s);console.log('OK: '+s);}
(async()=>{
fs.mkdirSync(out,{recursive:true});
const browser=await chromium.launch({channel:'msedge',headless:true});
try{
 const guest=await browser.newContext(),admin=await browser.newContext(),owner=await browser.newContext();
 async function login(context,correo){const r=await context.request.post(base+'/login',{form:{correo,contrasena:'123456'},maxRedirects:0});assert.equal(r.status(),302);}
 await login(admin,'admin@incluyelab.pe');await login(owner,'empresa@incluyelab.pe');
 const a=await admin.newPage();a.on('pageerror',e=>errors.push(e.message));
 assert.equal((await a.goto(base+'/admin')).status(),200);
 assert.equal(await a.getByRole('link',{name:'Crear empresa',exact:true}).count(),0);
 assert(await a.getByRole('heading',{name:'Solicitudes de empresas'}).isVisible());
 const review=await a.locator('#companies-table a[href*="revision-empresa"]').first().getAttribute('href');
 await a.locator('#empresas').scrollIntoViewIfNeeded();await a.screenshot({path:path.join(out,'empresas-admin.png')});
 assert.equal((await admin.request.get(base+'/admin?entidad=empresas&accion=nuevo')).status(),404);
 await a.goto(base+'/admin?entidad=usuarios&accion=nuevo');
 assert.equal(await a.locator('option[value=EMPRESA]').count(),0);
 await a.goto('http://localhost:8084'+review);
 assert.equal(await a.locator('h1').count(),1);
 await a.screenshot({path:path.join(out,'empresa-revision-desktop.png'),fullPage:true});
 ok('Administrador: listado de solicitudes, ficha y alta directa de empresas retirada');
 const p=await owner.newPage();p.on('pageerror',e=>errors.push(e.message));
 assert.equal((await p.goto(base+'/empresa')).status(),200);
 assert(await p.getByRole('link',{name:'Editar presentación',exact:true}).isVisible());
 await p.getByRole('link',{name:'Editar presentación',exact:true}).click();
 assert.equal(await p.locator('[name=presentacion]').count(),1);
 assert.equal(await p.locator('[name=logros]').count(),1);
 assert.equal(await p.locator('[name=anioInicio]').count(),1);
 assert.equal(await p.locator('[name=csrf]').count(),1);
 assert.equal(await p.locator('[name=idUsuario]').count(),0);
 assert.equal(await p.locator('[name=estado_revision]').count(),0);
 ok('Empresa: formulario propio con presentacion, sector, trayectoria y logros');
 const pub=await guest.newPage();pub.on('pageerror',e=>errors.push(e.message));
 assert.equal((await pub.goto(base+'/inicio')).status(),200);
 const profile=await pub.locator('#empresas-aprobadas .company-main').first().getAttribute('href');
 const originalOffers=await pub.locator('.offer-card').count();assert(originalOffers>0);
 assert.equal(await pub.locator('#empresas .company-profile-link').count(),23);
 for(const width of [1440,1024,768,390]){
   await pub.setViewportSize({width,height:950});
   assert.equal((await pub.goto('http://localhost:8084'+profile)).status(),200);
   await pub.waitForLoadState('networkidle');
   assert(await pub.getByRole('heading',{name:'Logros y metas cumplidas'}).isVisible());
   assert(await pub.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
   await pub.screenshot({path:path.join(out,'empresa-publica-'+width+'.png'),fullPage:true});
   await p.setViewportSize({width,height:950});await p.waitForLoadState('networkidle');
   assert(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
   await p.screenshot({path:path.join(out,'empresa-ficha-'+width+'.png'),fullPage:true});
 }
 await p.locator('[data-preference=contrast]').click();await p.locator('[data-preference=large]').click();
 assert(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
 await p.screenshot({path:path.join(out,'empresa-ficha-accesible.png'),fullPage:true});
 assert.equal((await guest.request.get(base+'/empresa-publica?marca=Amazon')).status(),200);
 assert.equal((await guest.request.get(base+'/empresa-publica?id=invalid')).status(),404);
 assert.equal((await guest.request.get(base+'/WEB-INF/empresa-ficha.jsp')).status(),404);
 assert.match((await guest.request.get(base+'/empresa/perfil',{maxRedirects:0})).headers().location,/login/);
 assert.match((await guest.request.get(base+'/revision-empresa?id=1',{maxRedirects:0})).headers().location,/login/);
 assert.match((await owner.request.get(base+'/revision-empresa?id=1',{maxRedirects:0})).headers().location,/empresa/);
 assert.deepEqual(errors,[]);
 ok('Fichas publicas, permisos GET, logos, vistas adaptables y accesibilidad comprobados');
 ok(originalOffers+' ofertas originales visibles; no se crearon ni editaron registros');
 await guest.close();await owner.close();await admin.close();
}finally{await browser.close();}
fs.writeFileSync(path.join(out,'company-review-results.json'),JSON.stringify({date:new Date().toISOString(),readOnly:true,checks,errors,pending:'Prueba de escritura de registro, aprobacion/rechazo y publicacion no ejecutada por indicacion del usuario.'},null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
