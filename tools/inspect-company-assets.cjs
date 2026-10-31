const {chromium}=require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const sites={
 sap:'https://news.sap.com/latinamerica/',
 sapdeveloper:'https://developers.sap.com/',
 sapcommunity:'https://community.sap.com/'
};
(async()=>{
 const browser=await chromium.launch({channel:'msedge',headless:true});
 try {
  const page=await browser.newPage();
  for(const [key,url] of Object.entries(sites)){
   try {
    const response=await page.request.get(url,{timeout:20000});
    const html=await response.text();
    const assets=await page.evaluate(({html,url})=>{
     const doc=new DOMParser().parseFromString(html,'text/html');
     return [...doc.querySelectorAll('img,link[rel*="icon"],meta[property="og:image"]')]
       .map(e=>({alt:e.getAttribute('alt'),src:e.getAttribute('src')||e.getAttribute('href')||e.getAttribute('content'),lazy:e.getAttribute('data-src')}))
       .filter(e=>/logo|brand|icon|amazon|walmart|sanna|sap/i.test([e.alt,e.src,e.lazy].join(' ')))
       .slice(0,20).map(e=>({...e,src:e.src?new URL(e.src,url).href:null}));
    },{html,url:response.url()});
    console.log(JSON.stringify({key,url,status:response.status(),assets}));
   }catch(e){console.log(JSON.stringify({key,error:e.message.slice(0,160)}));}
  }
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
