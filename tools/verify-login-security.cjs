const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const base='http://localhost:8084/Portal_Empleo_Inclusivo';
(async()=>{const browser=await chromium.launch({channel:'msedge',headless:true});try{
 const context=await browser.newContext({viewport:{width:1280,height:900}}),page=await context.newPage();
 await page.goto(base+'/registro');await page.waitForLoadState('networkidle');
 const rules=page.locator('[data-password-rules="contrasena"] [data-rule]');assert.equal(await rules.count(),6);
 await page.locator('#contrasena').fill('Abcdef1!');assert.equal(await page.locator('[data-password-rules="contrasena"] .is-met').count(),6);assert(await page.locator('#contrasena').evaluate(input=>input.checkValidity()));
 const out=path.join(__dirname,'../verification');fs.mkdirSync(out,{recursive:true});await page.screenshot({path:path.join(out,'registro-politica-contrasena.png'),fullPage:true});
 let response=await context.request.post(base+'/registro',{form:{rol:'POSTULANTE',nombre:'Prueba no creada',correo:'no-crear@prueba.local',contrasena:'debil'},maxRedirects:0});assert.equal(response.status(),200);assert.match(await response.text(),/entre 8 y 100 caracteres/);
 const attempt=async password=>{const r=await context.request.post(base+'/login',{form:{correo:'luis@correo.com',contrasena:password},maxRedirects:0});return await r.text();};
 assert.match(await attempt('incorrecta-1'),/Te quedan 2 intentos/);assert.match(await attempt('incorrecta-2'),/Te quedan 1 intento/);assert.match(await attempt('incorrecta-3'),/bloqueada temporalmente/);assert.match(await attempt('123456'),/bloqueada temporalmente/);
 await page.goto(base+'/login');await page.waitForLoadState('networkidle');assert(await page.getByText(/3 intentos incorrectos/).isVisible());await page.screenshot({path:path.join(out,'login-seguridad.png'),fullPage:true});
 console.log('Politica visual, validacion del servidor y bloqueo de 3 intentos verificados.');
}finally{await browser.close();}})().catch(error=>{console.error(error);process.exitCode=1;});
