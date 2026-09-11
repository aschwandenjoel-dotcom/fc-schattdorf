// Screenshot eines einzelnen Seitenabschnitts in Telefon-Breite.
//
// Chrome --screenshot zeigt nur den ersten Bildschirm, und weil der Hero
// 100svh hoch ist, sieht man damit nie, was darunter liegt. Dieses Skript
// steuert Chrome ueber das DevTools-Protokoll, setzt den Viewport NACH dem
// Laden (vorher greift die Vorgabe nicht, innerWidth blieb 1) und
// fotografiert den Bereich um ein Element samt Rand.
//
// Aufruf:  node scripts/screenshot-element.mjs <url> <css-selector> <breite> <out.png> [rand-px]
// z. B.    node scripts/screenshot-element.mjs http://localhost:8080/ .fcsh-parallax 390 /tmp/claim.png 120
// Braucht Node >= 22 (eingebautes WebSocket) und Google Chrome.
import { spawn } from 'node:child_process';
import { writeFileSync } from 'node:fs';
const [url, selector, width, out, rand='120'] = process.argv.slice(2);
const port = 9333 + Math.floor(Math.random()*500);
const chrome = spawn('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  ['--headless=new','--disable-gpu','--no-first-run','--hide-scrollbars',`--window-size=${width},800`,`--remote-debugging-port=${port}`,`--user-data-dir=${process.env.TMPDIR||'/tmp'}/cdp-${port}`,'about:blank'],{stdio:'ignore'});
const sleep = ms => new Promise(r=>setTimeout(r,ms));
let targets; for (let i=0;i<40;i++){ try{ targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); if(targets.length) break;}catch{} await sleep(250); }
const ws = new WebSocket(targets[0].webSocketDebuggerUrl);
await new Promise(r=>ws.onopen=r);
let id=0; const pending={};
ws.onmessage = e => { const m=JSON.parse(e.data); if(m.id&&pending[m.id]){pending[m.id](m); delete pending[m.id];} };
const send=(method,params={})=>new Promise(res=>{ const i=++id; pending[i]=res; ws.send(JSON.stringify({id:i,method,params})); });
await send('Page.enable'); await send('Page.navigate',{url}); await sleep(2500);
await send('Emulation.setDeviceMetricsOverride',{width:+width,height:800,deviceScaleFactor:1,mobile:false});
await sleep(1500);
const r = await send('Runtime.evaluate',{expression:`(()=>{const el=document.querySelector(${JSON.stringify(selector)}); if(!el) return null; const b=el.getBoundingClientRect(); return JSON.stringify({x:b.left+scrollX,y:b.top+scrollY,w:b.width,h:b.height,ph:document.documentElement.scrollHeight});})()`,returnByValue:true});
const b = JSON.parse(r.result.result.value);
if(!b){ console.error('Selector nicht gefunden'); chrome.kill(); process.exit(1); }
const y0=Math.max(0,b.y-+rand), h=Math.min(b.ph-y0, b.h+2*+rand);
const dbg = await send('Runtime.evaluate',{expression:`(()=>{const vw={innerWidth,cw:document.documentElement.clientWidth,bw:document.body.getBoundingClientRect().width};const el=document.querySelector(${JSON.stringify(selector)}); const cs=getComputedStyle(el); const kids=[...el.children].map(k=>{const b=k.getBoundingClientRect(); return k.className+':'+Math.round(b.height)+'px@'+Math.round(b.top+scrollY);}); return JSON.stringify({vw,height:cs.height,minHeight:cs.minHeight,padding:cs.padding,kids});})()`,returnByValue:true});
console.log('computed:', dbg.result.result.value);
// Liegt der Ausschnitt im Viewport, ohne captureBeyondViewport — das haengt
// auf manchen Seiten (Hero mit 100svh). Sonst Viewport auf den Ausschnitt legen.
const inView = (y0 + h) <= 800;
if (!inView) { await send('Emulation.setDeviceMetricsOverride',{width:+width,height:Math.ceil(h),deviceScaleFactor:1,mobile:false}); await send('Runtime.evaluate',{expression:`scrollTo(0,${y0})`}); await sleep(600); }
const shot = await send('Page.captureScreenshot',{format:'png',clip:{x:0,y:(inView? y0 : 0),width:+width,height:h,scale:1}});
writeFileSync(out, Buffer.from(shot.result.data,'base64'));
console.log(`ok: ${selector} bei y=${Math.round(b.y)} Hoehe ${Math.round(b.h)}px, Seite ${b.ph}px -> ${out}`);
ws.close(); chrome.kill();
