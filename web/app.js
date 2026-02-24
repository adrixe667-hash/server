const consoleOutput = document.getElementById('consoleOutput');
const apiStatus = document.getElementById('apiStatus');

function log(msg){
  const now = new Date().toISOString().replace('T',' ').slice(0,19);
  consoleOutput.textContent += `\n[${now}] ${msg}`;
  consoleOutput.scrollTop = consoleOutput.scrollHeight;
}

document.querySelectorAll('[data-action]').forEach(btn=>{
  btn.addEventListener('click', ()=>{
    const action = btn.dataset.action;
    log(`Acción: ${action} (esqueleto UI; conectar backend para ejecución real).`);
  });
});

apiStatus.textContent = 'Esqueleto local OK';
log('Panel cargado correctamente.');
