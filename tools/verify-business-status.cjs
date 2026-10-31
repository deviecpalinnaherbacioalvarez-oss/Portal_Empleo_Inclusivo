const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const base='http://localhost:8084/Portal_Empleo_Inclusivo';
(async()=>{const browser=await chromium.launch({channel:'msedge',headless:true});try{
 const context=await browser.newContext({viewport:{width:1774,height:900}});
 let response=await context.request.post(base+'/login',{form:{correo:'empresa@incluyelab.pe',contrasena:'123456'},maxRedirects:0});assert.equal(response.status(),302);
 const page=await context.newPage();await page.goto(base+'/empresa');await page.waitForLoadState('networkidle');
 await page.locator('button[data-preference="contrast"]').click();await page.locator('button[data-preference="large"]').click();
 const panel=await page.locator('.business-status').boundingBox(),button=await page.locator('.business-status .btn').boundingBox();assert(panel&&button);assert(button.x>=panel.x);assert(button.x+button.width<=panel.x+panel.width);assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
 const out=path.join(__dirname,'../verification');fs.mkdirSync(out,{recursive:true});await page.screenshot({path:path.join(out,'empresa-contraste-texto-grande.png'),fullPage:true});
 await page.setViewportSize({width:390,height:900});assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));const mobilePanel=await page.locator('.business-status').boundingBox(),mobileButton=await page.locator('.business-status .btn').boundingBox();assert(mobilePanel&&mobileButton&&mobileButton.x>=mobilePanel.x&&mobileButton.x+mobileButton.width<=mobilePanel.x+mobilePanel.width);
 console.log('Bloque de empresa verificado en contraste alto, texto grande y movil.');
}finally{await browser.close();}})().catch(error=>{console.error(error);process.exitCode=1;});
