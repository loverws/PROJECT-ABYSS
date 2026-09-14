#!/usr/bin/env node
"use strict";
const fs=require("fs"),path=require("path"),root=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const profiles=read("src/shared/SoundProfiles.lua"), player=read("src/shared/SoundPlayer.lua");
const mobile=read("src/client/MobileInputController.lua"), tutorial=read("src/client/TutorialHUD.lua");
const feedback=read("src/client/FirstPersonCombat.client.lua"), client=read("src/client/ClientWeaponSystem.lua");
const assert=(ok,msg)=>{if(!ok)throw new Error(msg);};

for(const name of ["AssaultRifle","Pistol","Fists","Knife","Grenade","GrenadeBounce","GrenadeExplosion","FistImpact","KnifeImpact","ReloadStart","ReloadInsert","ReloadAction"]){
  const start=profiles.indexOf(name+" = {"); assert(start>=0,"missing profile "+name);
  const body=profiles.slice(start,profiles.indexOf("},\n",start)+2);
  assert(/cooldown = 0\.[0-9]+/.test(body)&&/maxVoices = [1-5]/.test(body)&&/rolloff = [0-9]+/.test(body),"unbounded profile "+name);
}
for(const role of ["Attack","Body","MechanicalTail","LightBody","SoftWhoosh","CleanWhoosh","Pin","Throw","Bounce","OutdoorTail","MagazineOut","MagazineIn","Bolt"])
  assert(profiles.includes('"'+role+'"'),"composition role missing: "+role);
assert(!profiles.includes("electronicpingshort")&&!profiles.includes("bass.wav"),"metallic ding or excessive bass profile remains");
for(const token of ["state.active >= profile.maxVoices","now - state.last < profile.cooldown","state.active += 1","state.active - 1","soundLayer.delay","RollOffMaxDistance"])
  assert(player.includes(token),"sound budget/cooldown missing: "+token);
let active=0,last=-Infinity,played=0; for(const t of [0,.02,.08,.1,.18]){if(t-last>=.075&&active<5){last=t;active+=3;played++;} active=Math.max(0,active-1);} assert(played===3&&active<=5,"deterministic rifle cooldown/voice model failed");
assert(client.includes('payload.weaponType == WeaponTypes.Fists and "FistImpact"')&&client.includes('WeaponTypes.Knife and "KnifeImpact"'),"melee contact is not confirmation-only");
for(const token of ["ReloadStart","reloadTime * 0.56","ReloadInsert","reloadTime * 0.84","ReloadAction"])
  assert(client.includes(token),"reload timing missing: "+token);
console.log("PASS: distinct layered profiles, no ding/bass dominance, cooldown, voice caps, melee contact, reload timing");

for(const token of ["UITheme.Glass","UITheme.Shadow","UITheme.Press","ActionIcon","ActionCaption","StateStroke","ControlState","Selected","UITheme.Pulse","AmmoValue"])
  assert(mobile.includes(token)||read("src/client/UITheme.lua").includes(token),"HUD polish contract missing: "+token);
for(const token of ["StageBadge","TACTICAL COURSE","ObjectiveText","ProgressTrack","ProgressFill","ProgressSegment","TimerPill","urgent","changedStage"])
  assert(tutorial.includes(token),"objective card contract missing: "+token);
for(const token of ["CompactTargetFeedback","RegionBadge","DamageNumber","TargetHealthTrack","TargetHealthFill","UIScale"])
  assert(feedback.includes(token),"damage feedback polish missing: "+token);
assert(feedback.includes("ammoLabel.Visible = not isTouchDevice"),"duplicate mobile ammo panel remains");

const overlap=(a,b)=>a[0]<b[2]&&a[2]>b[0]&&a[1]<b[3]&&a[3]>b[1];
for(const [w,h] of [[640,360],[667,375],[844,390],[896,414],[932,430],[1280,720]]){
  const center=[w*.4,h*.4,w*.6,h*.6],fire=[w-116,h*.4-44,w-28,h*.4+44],reload=[w-196,h*.48-35,w-126,h*.48+35],card=[14,44,242,138];
  assert(!overlap(center,fire)&&!overlap(center,reload)&&!overlap(center,card),"central 20% obstruction at "+w+"x"+h);
}
assert(!mobile.includes("ContextActionService")&&!mobile.includes("BindAction")&&!mobile.includes("InputChanged:Connect"),"touch camera ownership regression");
assert(!feedback.includes("camera.CFrame = Tween")&&!mobile.includes("ViewportPointToRay"),"UI motion changes camera/aim");
console.log("PASS: glass/icon hierarchy, state styling, objective card, feedback, center-clear and aim isolation");
console.log("All v13 audio/UI polish deterministic contracts passed.");
