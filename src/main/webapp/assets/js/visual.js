/* Ayuda visual voluntaria. Mantiene el teclado nativo de formularios y widgets. */
(() => {
    'use strict';
    const all = (selector, root = document) => [...root.querySelectorAll(selector)];
    const status = message => all('[data-visual-status]').forEach(node => { node.textContent = message; });
    const visible = node => node.getClientRects().length > 0
        && getComputedStyle(node).visibility === 'visible'
        && !node.closest('[hidden], [inert], [aria-hidden="true"]');
    const modal = () => document.querySelector('dialog[open], .modal.show');
    const content = () => {
        const activeModal = modal();
        return activeModal?.querySelector('.dialog-content, .modal-body') || activeModal
            || document.querySelector('main, [role="main"]');
    };
    const main = document.querySelector('#contenido');
    if (main && !main.hasAttribute('tabindex')) main.tabIndex = -1;
    // Las flechas requieren activación explícita en cada carga de página.
    // La voz al navegar empieza apagada y, una vez activada, se recuerda entre páginas.
    const voiceKey = 'incluyelab.vozNavegar';
    const rememberReadFocus = value => { try { localStorage.setItem(voiceKey, value ? '1' : '0'); } catch (_) { /* sin almacenamiento */ } };
    let arrows = false;
    let readFocus = (() => { try { return localStorage.getItem(voiceKey) === '1'; } catch (_) { return false; } })();
    let muted = false;
    const updateArrows = () => {
        document.documentElement.classList.toggle('arrow-navigation', arrows);
        all('[data-arrow-navigation]').forEach(button => button.setAttribute('aria-pressed', String(arrows)));
    };
    const updateReadFocus = () => {
        all('[data-read-focus-toggle]').forEach(button => {
            button.setAttribute('aria-pressed', String(readFocus));
            // La barra superior conserva su icono y muestra el estado con aria-pressed.
            if (!button.closest('.a11y-controls')) button.textContent = readFocus ? 'Desactivar voz al navegar' : 'Activar voz al navegar';
        });
    };
    updateArrows();
    updateReadFocus();

    const supported = 'speechSynthesis' in window && typeof window.SpeechSynthesisUtterance === 'function';
    const synth = supported ? window.speechSynthesis : null;
    let generation = 0;
    let currentUtterance = null;
    let reading = false;
    let pageReading = false;
    let paused = false;
    let spanishVoice = null;
    const updateVoice = () => {
        const voices = synth.getVoices();
        spanishVoice = voices.find(voice => /^es[-_]PE$/i.test(voice.lang))
            || voices.find(voice => /^es(?:[-_]|$)/i.test(voice.lang)) || null;
    };
    const updateSpeechControls = () => {
        all('[data-read-page], [data-read-focus-toggle]').forEach(control => { control.disabled = !supported; });
        all('[data-read-pause]').forEach(button => {
            button.disabled = !reading;
            button.textContent = paused ? 'Continuar lectura' : 'Pausar lectura';
        });
        all('[data-read-stop]').forEach(button => { button.disabled = !reading; });
        all('[data-read-mute]').forEach(button => {
            button.disabled = !supported;
            button.setAttribute('aria-pressed', String(muted));
            button.setAttribute('aria-label', muted ? 'Activar lectura' : 'Silenciar lectura');
            button.title = muted ? 'Activar lectura' : 'Silenciar lectura';
        });
    };
    function stop(message = '') {
        generation++;
        reading = false;
        paused = false;
        currentUtterance = null;
        synth?.cancel();
        updateSpeechControls();
        if (message) status(message);
    }
    // Recoge solo texto visible y descripciones de imágenes. Nunca lee valores escritos.
    function textToRead(root) {
        if (!root) return '';
        const parts = [];
        const skip = 'script, style, template, noscript, input, textarea, select, [data-no-read], [data-visual-status]';
        const visit = node => {
            if (node.nodeType === Node.TEXT_NODE) {
                if (node.textContent.trim()) parts.push(node.textContent.trim());
                return;
            }
            if (!(node instanceof Element) || node.matches(skip) || !visible(node)) return;
            if (node.tagName === 'IMG') {
                if (node.alt.trim()) parts.push(node.alt.trim());
                return;
            }
            for (const child of node.childNodes) visit(child);
        };
        visit(root);
        return parts.join(' ').replace(/\s+/g, ' ').trim();
    }
    function speak(text, announce = true) {
        if (!supported) return;
        if (muted) return;
        stop();
        if (!text) { status('No hay contenido visible para leer.'); return; }
        // Frases cortas evitan que una página larga se pierda en una única locución.
        const chunks = text.match(/.{1,220}(?:\s|$)|\S{1,220}/g) || [text];
        const token = generation;
        reading = true;
        pageReading = announce;
        updateSpeechControls();
        if (announce) status('Lectura iniciada. Puedes pausarla o detenerla con Escape.');
        const next = index => {
            if (token !== generation) return;
            if (index >= chunks.length) {
                reading = false;
                currentUtterance = null;
                updateSpeechControls();
                if (announce) status('Lectura finalizada.');
                return;
            }
            const utterance = new SpeechSynthesisUtterance(chunks[index]);
            currentUtterance = utterance;
            utterance.lang = 'es-PE';
            if (spanishVoice) utterance.voice = spanishVoice;
            utterance.rate = 0.95;
            utterance.onend = () => next(index + 1);
            utterance.onerror = event => {
                if (token !== generation) return;
                stop(event.error === 'not-allowed'
                    ? 'El navegador bloqueó la voz. Pulsa Escuchar página para intentarlo otra vez.'
                    : 'No se pudo reproducir la voz. Comprueba las voces y el sonido de tu navegador.');
            };
            try { synth.speak(utterance); }
            catch (_) { stop('La voz no está disponible en este navegador. Puedes usar tu lector de pantalla.'); }
        };
        synth.resume();
        next(0);
    }
    if (supported) {
        updateVoice();
        synth.addEventListener('voiceschanged', updateVoice);
    } else {
        status('La voz no está disponible en este navegador. Puedes usar un lector de pantalla; el contraste, el texto y el teclado siguen disponibles.');
    }
    updateSpeechControls();
    document.addEventListener('click', event => {
        const button = event.target.closest('[data-read-page], [data-read-stop], [data-read-pause], [data-read-mute], [data-arrow-navigation], [data-read-focus-toggle]');
        if (!button || button.disabled) return;
        if (button.matches('[data-read-page]')) {
            muted = false;
            updateSpeechControls();
            speak(textToRead(content()));
        }
        if (button.matches('[data-read-stop]')) stop('Lectura detenida.');
        if (button.matches('[data-read-pause]')) {
            paused = !paused;
            if (paused) synth.pause(); else synth.resume();
            updateSpeechControls();
            status(paused ? 'Lectura en pausa.' : 'Lectura reanudada.');
        }
        if (button.matches('[data-read-mute]')) {
            muted = !muted;
            if (muted) stop('Lectura silenciada.');
            else status('Lectura disponible. Activa la voz al navegar si deseas escuchar cada control.');
            updateSpeechControls();
        }
        if (button.matches('[data-arrow-navigation]')) {
            arrows = !arrows;
            updateArrows();
            status(arrows ? 'Flechas activadas para enlaces y botones. Dentro de los campos conservan su función habitual.' : 'Flechas desactivadas. Puedes seguir usando Tab.');
        }
        if (button.matches('[data-read-focus-toggle]')) {
            readFocus = !readFocus;
            rememberReadFocus(readFocus);
            updateReadFocus();
            // La confirmación se dice en voz alta: quien no ve el mensaje también se entera.
            if (!readFocus) {
                status('Voz al navegar desactivada.');
                speak('Voz al navegar desactivada', false);
            } else {
                muted = false;
                updateSpeechControls();
                status('Voz al navegar activada. Se mantendrá en las demás páginas hasta que la desactives.');
                speak('Voz al navegar activada', false);
            }
        }
    });
    const focusables = 'a[href], button, input:not([type="hidden"]), select, textarea, summary, [tabindex="0"]';
    const nativeArrows = 'input, textarea, select, [contenteditable]:not([contenteditable="false"]), [role="textbox"], [role="slider"], [role="spinbutton"], [role="tablist"], [role="menu"], [role="listbox"], [role="tree"], [role="grid"], [role="region"][tabindex]';
    document.addEventListener('keydown', event => {
        if (event.key === 'Escape') { if (reading) stop('Lectura detenida.'); return; }
        if (!arrows || event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey
            || !['ArrowDown', 'ArrowRight', 'ArrowUp', 'ArrowLeft'].includes(event.key)
            || event.target.matches('input, textarea, select') || event.target.closest(nativeArrows)) return;
        const scope = modal() || document;
        const controls = all(focusables, scope).filter(node => visible(node) && !node.disabled && node.tabIndex >= 0);
        if (!controls.length) return;
        const current = controls.indexOf(document.activeElement);
        const forward = event.key === 'ArrowDown' || event.key === 'ArrowRight';
        const index = current < 0 ? (forward ? 0 : controls.length - 1) : current + (forward ? 1 : -1);
        if (index < 0 || index >= controls.length) return;
        event.preventDefault();
        controls[index].focus();
    });
    // Texto que se anuncia para un control: tipo, nombre y estado.
    function describe(node) {
        const exactLabel = node.getAttribute('data-speech-label');
        if (exactLabel) return exactLabel;
        const label = (node.getAttribute('aria-label')
            || (node.labels ? [...node.labels].map(item => item.textContent.trim()).join('. ') : '')
            || node.textContent.trim() || node.title || '').replace(/\s+/g, ' ').trim();
        if (!label) return '';
        // Las tarjetas enlazadas tienen mucho texto: basta con el inicio para reconocerlas.
        const name = label.length > 200 ? label.slice(0, 200).replace(/\s+\S*$/, '') + '…' : label;
        const type = node.matches('input, textarea, select') ? 'Campo. '
            : node.matches('a') ? 'Enlace. ' : 'Control. ';
        // Solo nombre y estado, incluso si el usuario mostró su contraseña.
        const state = node.hasAttribute('aria-pressed') ? (node.getAttribute('aria-pressed') === 'true' ? '. Activado' : '. Desactivado')
            : node.matches('summary') ? (node.parentElement.open ? '. Desplegado' : '. Plegado') : '';
        // En listas se dice la opción elegida y en casillas si están marcadas; nunca el texto escrito.
        const choice = node.matches('select') && node.selectedOptions.length ? '. ' + node.selectedOptions[0].textContent.trim()
            : node.matches('input[type="checkbox"], input[type="radio"]') ? (node.checked ? '. Marcado' : '. Sin marcar') : '';
        return type + name + state + choice;
    }
    document.addEventListener('change', event => {
        const node = event.target;
        if (!readFocus || !supported || !node.matches('select, input[type="checkbox"], input[type="radio"]')) return;
        speak(describe(node), false);
    });
    // Un clic con ratón también enfoca el control; ese foco no se anuncia porque el
    // ratón ya lo leyó al pasar por encima y el clic anuncia el estado nuevo.
    let pointerFocus = false;
    let hoverTarget = null;
    let hoverTimer = 0;
    document.addEventListener('pointerdown', event => {
        if (event.pointerType !== 'mouse') return;
        // El clic anuncia el estado nuevo; se descarta la lectura pendiente del ratón.
        clearTimeout(hoverTimer);
        pointerFocus = true;
        setTimeout(() => { pointerFocus = false; }, 0);
    }, true);
    document.addEventListener('focusin', event => {
        const node = event.target;
        if (!readFocus || !supported || pointerFocus || !node.matches(focusables)
            || node.matches('[data-read-page], [data-read-stop], [data-read-pause]')) return;
        const text = describe(node);
        if (text) speak(text, false);
    });
    // Se escucha el movimiento y no "pointerover": si la página cambia de forma bajo un
    // ratón quieto (por ejemplo, al aparecer el campo RUC) no se interrumpe lo que se está diciendo.
    document.addEventListener('pointermove', event => {
        if (event.pointerType !== 'mouse' || !readFocus || !supported) return;
        const control = event.target.closest(focusables);
        if (control === hoverTarget) return;
        hoverTarget = control;
        clearTimeout(hoverTimer);
        // Una pausa breve evita que hable sin parar al cruzar la página; no corta "Escuchar página".
        if (!control || (reading && pageReading) || !visible(control)) return;
        hoverTimer = setTimeout(() => {
            const text = describe(control);
            if (text) speak(text, false);
        }, 350);
    }, { passive: true });
    document.addEventListener('click', event => {
        if (!readFocus || !supported) return;
        const control = event.target.closest('[aria-pressed], summary');
        if (!control || control.matches('[data-read-focus-toggle], [data-read-mute]')) return;
        // Espera a que el botón cambie su estado para anunciar el nuevo, no el anterior.
        setTimeout(() => speak(describe(control), false), 0);
    });
    document.addEventListener('close', event => { if (event.target.matches('dialog')) stop(); }, true);
    document.addEventListener('hidden.bs.modal', () => stop());
    window.addEventListener('pagehide', () => stop());
})();
