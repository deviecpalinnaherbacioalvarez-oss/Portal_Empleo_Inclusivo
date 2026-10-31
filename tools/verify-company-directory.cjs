const fs=require('fs');
const path=require('path');
const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const base=process.env.PORTAL_URL||'http://localhost:8084/Portal_Empleo_Inclusivo';
const output=path.join(__dirname,'../verification');
(async()=>{
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const errors=[];
 try{
  const page=await browser.newPage({viewport:{width:1440,height:1050}});
  page.on('pageerror',e=>errors.push(e.message));
  page.on('response',r=>{if(r.url().startsWith(base)&&r.status()>=400)errors.push(r.status()+': '+r.url());});
  await page.goto(base+'/inicio');await page.waitForLoadState('networkidle');
  assert.equal(await page.locator('#empresas .company-tile').count(),23);
  assert(!(await page.locator('body').innerText()).includes('TechForGood'));
  assert.equal(await page.locator('.company-official').count(),23);
  await page.locator('#empresas').scrollIntoViewIfNeeded();
  const broken=await page.locator('#empresas .company-tile img').evaluateAll(async images=>{
    await Promise.all(images.map(img=>img.decode().catch(()=>{})));
    return images.filter(img=>!img.naturalWidth).map(img=>img.src);
  });
  assert.deepEqual(broken,[]);
  await page.locator('#empresas .company-grid').screenshot({path:path.join(output,'directorio-23-marcas.png')});
  for(const name of ['Microsoft','Amazon','Walmart','Mercado Libre','Falabella','SAP','ACCIONA','Clínica Internacional','Clínica San Pablo Surco','Pardos Chicken']){
    const card=page.locator('#empresas .company-tile').filter({has:page.getByText(name,{exact:true})});
    assert.equal(await card.count(),1);
    assert.match(await card.locator('.company-official').getAttribute('href'),/^https:\/\//);
    await card.locator('.company-main').click();await page.waitForLoadState('networkidle');
    assert.equal(await page.locator('#company-filter').inputValue(),name);
    if(name==='Microsoft')assert.equal(await page.locator('.offer-card:visible').count(),3);
    else assert(await page.locator('#empty-results').isVisible());
    await page.goto(base+'/inicio#empresas');await page.waitForLoadState('networkidle');
  }
  await page.setViewportSize({width:390,height:900});
  await page.locator('#empresas').scrollIntoViewIfNeeded();
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await page.screenshot({path:path.join(output,'directorio-movil.png')});
  await page.locator('[data-preference=contrast]').click();
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  assert.deepEqual(errors,[]);
  fs.writeFileSync(path.join(output,'directory-results.json'),JSON.stringify({date:new Date().toISOString(),brands:23,logosDecoded:23,filtersTested:10,errors,readOnly:true},null,2));
  console.log('23 marcas, 23 logos, 23 sitios oficiales; 10 filtros y vista movil verificados. Sin crear empresas ni ofertas.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
