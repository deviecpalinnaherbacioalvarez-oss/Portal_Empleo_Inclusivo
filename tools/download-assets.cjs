const https = require('https');
const fs = require('fs');
const path = require('path');
const base = path.join(__dirname, '../src/main/webapp/assets');
function get(url, n=0) { return new Promise((resolve,reject)=>{
  const req=https.get(url,{headers:{'User-Agent':'Mozilla/5.0'}},res=>{
    if(res.statusCode>=300&&res.statusCode<400&&res.headers.location&&n<6){res.resume();return get(new URL(res.headers.location,url).href,n+1).then(resolve,reject);}
    const parts=[];res.on('data',x=>parts.push(x));res.on('end',()=>res.statusCode===200?resolve({data:Buffer.concat(parts),type:res.headers['content-type']||''}):reject(new Error(String(res.statusCode))));
  });req.setTimeout(20000,()=>req.destroy(new Error('timeout')));req.on('error',reject);
}); }
const sources={
 upn:'https://www.upn.edu.pe/sites/default/files/logo-upn-nuevo.svg',
 utp:'https://commons.wikimedia.org/wiki/Special:FilePath/UTP-logo.svg',
 yape:'https://www.yape.com.pe/images/components/component-25/logo.png',
 claro:'https://www.claro.com.pe/portal/pe/recursos_tema_evo/assets/internal/icon-touch-144.png',
 movistar:'https://cert-cdn.movistar.com.pe/2024/12/logo-2.svg',
 entel:'https://entel.cdn.modyo.com/uploads/c75391f7-024a-49a2-99da-d388658a25d0/original/favicon-entel-180x180.webp',
 rimac:'https://www.rimac.com/js/apple-touch-icon.png',
 inkafarma:'https://commons.wikimedia.org/wiki/Special:FilePath/Logo_de_Inkafarma.png',
 tottus:'https://images.falabella.com/v3/assets/blt7c5c2f2f888a7cc3/blt731539d15505e022/Tottus@192px.png',
 sodimac:'https://images.sodimac.com/v3/assets/blt6a203fe6c6a9b6dd/bltcf215412183f0b18/Sodimac192.png',
 alicorp:'https://upload.wikimedia.org/wikipedia/commons/1/16/Alicorp_Logo_2023.png',
 bcp:'https://upload.wikimedia.org/wikipedia/commons/0/0d/Logo-bcp-vector.svg',
 interbank:'https://upload.wikimedia.org/wikipedia/commons/c/ca/Interbank_logo.svg'
};
async function main(){
 fs.mkdirSync(path.join(base,'logos'),{recursive:true});fs.mkdirSync(path.join(base,'vendor'),{recursive:true});
 const manifestPath=path.join(base,'logos/sources.json');
 const manifest=fs.existsSync(manifestPath)?JSON.parse(fs.readFileSync(manifestPath,'utf8')):{};
 await Promise.all(Object.entries(sources).map(async([key,url])=>{try{const {data,type}=await get(url);if(/html/.test(type))throw new Error('not an image');const ext=type.includes('svg')?'svg':type.includes('webp')?'webp':type.includes('png')?'png':'ico';fs.writeFileSync(path.join(base,'logos',key+'.'+ext),data);manifest[key]={file:key+'.'+ext,source:url};console.log(key+' OK '+data.length);}catch(e){console.log(key+' FAILED '+e.message);}}));
 const icons=await get('https://unpkg.com/lucide@0.468.0/dist/umd/lucide.min.js');fs.writeFileSync(path.join(base,'vendor/lucide.min.js'),icons.data);
 const fontCss=(await get('https://fonts.googleapis.com/css2?family=Ubuntu:wght@400;500;700&family=Atkinson+Hyperlegible:wght@400;700&display=swap')).data.toString();
 fs.mkdirSync(path.join(base,'fonts'),{recursive:true});let localCss=fontCss;
 let i=0;for(const match of [...fontCss.matchAll(/url\((https[^)]+)\)/g)]){const url=match[1];const filename='font-'+(i++)+(url.includes('.woff2')?'.woff2':'.ttf');fs.writeFileSync(path.join(base,'fonts',filename),(await get(url)).data);localCss=localCss.replace(url,filename);}
 fs.writeFileSync(path.join(base,'fonts/fonts.css'),localCss);
 fs.writeFileSync(path.join(base,'logos/sources.json'),JSON.stringify(manifest,null,2));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
