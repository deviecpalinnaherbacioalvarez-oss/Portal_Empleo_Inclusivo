const fs=require('fs');
const path=require('path');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const sources={
 microsoft:['microsoft.png','https://uhf.microsoft.com/images/microsoft/RE1Mu3b.png','https://www.microsoft.com/es-pe/'],
 amazon:['amazon.png','https://www.aboutamazon.com/_next/static/media/apple-touch-icon.706b1b87.png','https://www.aboutamazon.com/'],
 walmart:['walmart.svg','https://corporate.walmart.com/content/dam/corporate/site-images/WMT-Spark-New-SparkYellow-RGB.svg','https://corporate.walmart.com/'],
 mercadolibre:['mercadolibre.png','https://news.mercadolibre.com/themes/custom/mercadolibre/logo.png','https://news.mercadolibre.com/'],
 falabella:['falabella.png','https://images.falabella.com/v3/assets/blt7c5c2f2f888a7cc3/bltde5263bea5336415/Logo%20favicon@144px.png','https://www.falabella.com.pe/'],
 sap:['sap.svg','https://developers.sap.com/img/sap-logo.svg','https://www.sap.com/'],
 acciona:['acciona.jpg','https://www.acciona.com/content/dam/accionacom/media/1371193/acciona_oglogo.jpg','https://www.acciona.com/es/'],
 internacional:['internacional.png','https://clinicainternacional.com.pe/assets/logos/logo.png','https://www.clinicainternacional.com.pe/'],
 sanpablo:['sanpablo.png','https://www.sanpablo.com.pe/wp-content/uploads/2024/05/LogoSPSurco.png','https://www.sanpablo.com.pe/'],
 pardos:['pardos.png','https://www.pardoschicken.pe/assets/images/pardos.svg','https://www.pardoschicken.pe/']
};
(async()=>{
 const dir=path.join(__dirname,'../src/main/webapp/assets/logos');
 const manifest=JSON.parse(fs.readFileSync(path.join(dir,'sources.json'),'utf8'));
 const browser=await chromium.launch({channel:'msedge',headless:true});
 try{
  const context=await browser.newContext();
  for(const [brand,[file,url,website]] of Object.entries(sources)){
   try{
    const response=await context.request.get(url,{timeout:25000});
    if(!response.ok()||!response.headers()['content-type']?.includes('image'))throw new Error('HTTP '+response.status()+' '+response.headers()['content-type']);
    const data=await response.body();fs.writeFileSync(path.join(dir,file),data);
    manifest[brand]={file,source:url,website};console.log(brand+' OK '+data.length);
   }catch(e){console.error(brand+' FAILED '+e.message);process.exitCode=1;}
  }
  fs.writeFileSync(path.join(dir,'sources.json'),JSON.stringify(manifest,null,2)+'\n');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
