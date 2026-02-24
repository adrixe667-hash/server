const consoleOutput = document.getElementById('consoleOutput');
const apiStatus = document.getElementById('apiStatus');

function log(msg){
  const now = new Date().toISOString();
  consoleOutput.textContent += `\n[${now}] ${msg}`;
}

document.querySelectorAll('[data-action]').forEach(btn=>{
  btn.addEventListener('click', ()=>{
    const action = btn.dataset.action;
    log(`Acción solicitada: ${action}. (Conectar backend para ejecutar scripts)`);
  });
});

// Demo placeholder de estado
apiStatus.textContent = 'Esqueleto local';
