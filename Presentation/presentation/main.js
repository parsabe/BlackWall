import Swiper from 'swiper';
// 1. Import the Keyboard module
import { Navigation, Keyboard } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/navigation';
import './main.scss';
import SwiperGL from './swiper-gl.esm.js';
import './swiper-gl.scss';

const swiper = new Swiper('.swiper', {
  // 2. Add Keyboard to the modules list
  modules: [Navigation, Keyboard, SwiperGL],
  speed: 1000,
  effect: 'gl',
  loop: true,
  gl: {
    shader: 'random',
  },
  // 3. Configure the keyboard
  keyboard: {
    enabled: true,
    // Optional: ensures keyboard works even if you haven't clicked the slider yet
    onlyInViewport: false,
  },
  navigation: {
    prevEl: '.swiper-button-prev',
    nextEl: '.swiper-button-next',
  },
});

// --- Shader Picker Logic (Unchanged) ---
const pickerEl = document.querySelector('.demo-shader-picker');
const optionsEl = document.querySelector('.demo-shader-options');

if (pickerEl && optionsEl) {
  // Added a small safety check in case these elements don't exist
  const setShader = (shader) => {
    document.querySelector('.demo-shader-current').textContent = shader;
    swiper.gl.replaceShader(shader);
  };
  document
    .querySelector('.demo-shader-selector')
    .addEventListener('click', () => {
      optionsEl.style.display =
        optionsEl.style.display === 'none' || !optionsEl.style.display
          ? 'block'
          : 'none';
    });

  optionsEl.addEventListener('click', (e) => {
    if (e.target.nodeName === 'SPAN') {
      setShader(e.target.textContent.trim());
      optionsEl.style.display = 'none';
    }
  });
  document.addEventListener('click', (e) => {
    if (pickerEl.contains(e.target)) return;
    optionsEl.style.display = 'none';
  });
}
