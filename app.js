const zodiacSigns = [
  { key:'capricorn', name:'염소자리', period:'12월 22일 — 1월 19일', start:[12,22], end:[1,19], symbol:'바다염소', element:'흙', star:'데네브 알게디', summary:'끈기 있게 산을 오르는 염소처럼, 차분하게 목표를 향해 가는 별자리예요.', points:'48,136 85,95 126,122 174,66 214,94 259,43', stars:[[48,136,5],[85,95,4],[126,122,5],[174,66,4],[214,94,5],[259,43,4]] },
  { key:'aquarius', name:'물병자리', period:'1월 20일 — 2월 18일', start:[1,20], end:[2,18], symbol:'물병', element:'공기', star:'사달수드', summary:'물병에서 새 지식을 흘려보내듯, 기발한 생각을 나누는 별자리예요.', points:'41,73 84,103 115,65 154,109 187,71 232,110 278,73', stars:[[41,73,4],[84,103,5],[115,65,4],[154,109,5],[187,71,4],[232,110,5],[278,73,4]] },
  { key:'pisces', name:'물고기자리', period:'2월 19일 — 3월 20일', start:[2,19], end:[3,20], symbol:'물고기 두 마리', element:'물', star:'알레샤', summary:'서로를 이어 주는 줄처럼, 상상력과 공감이 반짝이는 별자리예요.', points:'49,74 85,49 111,83 80,120 49,74 M111,83 171,104 221,67 256,103 224,140 171,104', stars:[[49,74,4],[85,49,5],[111,83,4],[80,120,5],[171,104,5],[221,67,4],[256,103,5],[224,140,4]] },
  { key:'aries', name:'양자리', period:'3월 21일 — 4월 19일', start:[3,21], end:[4,19], symbol:'숫양', element:'불', star:'하말', summary:'봄의 시작을 알리듯, 새로운 일에 먼저 용기 내어 다가가는 별자리예요.', points:'56,135 100,94 155,107 205,56 256,82', stars:[[56,135,4],[100,94,5],[155,107,4],[205,56,5],[256,82,4]] },
  { key:'taurus', name:'황소자리', period:'4월 20일 — 5월 20일', start:[4,20], end:[5,20], symbol:'황소', element:'흙', star:'알데바란', summary:'황소의 단단한 뿔처럼, 좋아하는 일을 꾸준히 해내는 별자리예요.', points:'62,49 102,85 144,123 190,83 235,43 M144,123 202,143 258,118', stars:[[62,49,4],[102,85,5],[144,123,5],[190,83,4],[235,43,5],[202,143,4],[258,118,4]] },
  { key:'gemini', name:'쌍둥이자리', period:'5월 21일 — 6월 21일', start:[5,21], end:[6,21], symbol:'쌍둥이', element:'공기', star:'카스토르 · 폴룩스', summary:'나란히 빛나는 두 별처럼, 대화와 호기심을 좋아하는 별자리예요.', points:'76,43 99,81 93,129 137,151 M191,45 166,81 172,128 137,151', stars:[[76,43,5],[99,81,4],[93,129,4],[137,151,5],[191,45,5],[166,81,4],[172,128,4]] },
  { key:'cancer', name:'게자리', period:'6월 22일 — 7월 22일', start:[6,22], end:[7,22], symbol:'게', element:'물', star:'아쿠벤스', summary:'옆으로도 잘 걷는 게처럼, 나만의 방식으로 주변을 세심하게 살피는 별자리예요.', points:'51,92 98,62 142,96 191,58 238,91 M142,96 138,139', stars:[[51,92,4],[98,62,5],[142,96,4],[191,58,5],[238,91,4],[138,139,4]] },
  { key:'leo', name:'사자자리', period:'7월 23일 — 8월 22일', start:[7,23], end:[8,22], symbol:'사자', element:'불', star:'레굴루스', summary:'사자의 갈기처럼 존재감이 반짝여요. 함께하는 사람을 응원하는 힘도 있어요.', points:'51,62 97,43 127,84 169,60 206,96 187,139 139,145 116,110 M206,96 254,61', stars:[[51,62,4],[97,43,5],[127,84,4],[169,60,4],[206,96,5],[187,139,4],[139,145,4],[116,110,4],[254,61,4]] },
  { key:'virgo', name:'처녀자리', period:'8월 23일 — 9월 22일', start:[8,23], end:[9,22], symbol:'곡식 이삭', element:'흙', star:'스피카', summary:'잘 익은 이삭을 품은 별자리예요. 작은 차이를 발견하는 관찰력이 빛나요.', points:'60,53 101,80 142,55 179,91 219,65 248,111 205,141 159,121 116,149', stars:[[60,53,4],[101,80,4],[142,55,5],[179,91,4],[219,65,4],[248,111,5],[205,141,4],[159,121,4],[116,149,4]] },
  { key:'libra', name:'천칭자리', period:'9월 23일 — 10월 22일', start:[9,23], end:[10,22], symbol:'저울', element:'공기', star:'주벤엘게누비', summary:'양쪽의 무게를 살피는 저울처럼, 조화로운 방법을 찾는 별자리예요.', points:'58,72 108,104 157,62 206,104 257,72 M108,104 157,143 206,104', stars:[[58,72,4],[108,104,5],[157,62,4],[206,104,5],[257,72,4],[157,143,4]] },
  { key:'scorpio', name:'전갈자리', period:'10월 23일 — 11월 21일', start:[10,23], end:[11,21], symbol:'전갈', element:'물', star:'안타레스', summary:'굽은 꼬리처럼 인상적인 모양을 가진, 깊은 집중력이 돋보이는 별자리예요.', points:'48,57 93,82 132,65 168,105 207,89 242,126 219,151 260,158', stars:[[48,57,4],[93,82,4],[132,65,4],[168,105,6],[207,89,4],[242,126,4],[219,151,4],[260,158,4]] },
  { key:'sagittarius', name:'사수자리', period:'11월 22일 — 12월 21일', start:[11,22], end:[12,21], symbol:'궁수', element:'불', star:'카우스 아우스트랄리스', summary:'화살이 향하는 곳처럼, 넓은 세상과 새로운 질문을 향해 나아가는 별자리예요.', points:'65,58 113,88 166,56 211,91 164,129 114,115 65,143 M164,129 217,150', stars:[[65,58,4],[113,88,4],[166,56,5],[211,91,4],[164,129,5],[114,115,4],[65,143,4],[217,150,4]] }
];

const zodiacImageFiles = {
  capricorn:'cap', aquarius:'aqr', pisces:'psc', aries:'ari', taurus:'tau', gemini:'gem',
  cancer:'cnc', leo:'leo', virgo:'vir', libra:'lib', scorpio:'sco', sagittarius:'sgr'
};

const festivalDate = '2026-10-14';
const firestoreDocumentUrl = 'https://firestore.googleapis.com/v1/projects/bit-code-lab-2026/databases/%28default%29/documents/festivalHoroscopes/2026-10-14?key=AIzaSyBUZ1IU5exTw3gELm7criA7ECT_Z4osld4';
const fortuneCategories = [
  ['overall', '총운'],
  ['love', '애정운'],
  ['money', '금전운'],
  ['study', '학업운'],
  ['health', '건강운']
];

const yearlyFortuneParts = {
  tones: ['차분한', '선명한', '따뜻한', '용감한', '유연한', '반짝이는', '단단한', '새로운', '조화로운', '깊이 있는'],
  strengths: ['관찰력', '호기심', '집중력', '표현력', '계획성', '협동심', '상상력', '꾸준함', '판단력', '회복력'],
  rhythms: ['한 걸음씩', '침착하게', '대담하게', '꼼꼼하게', '가볍게', '꾸준히', '솔직하게', '즐겁게', '균형 있게', '끝까지'],
  actions: ['첫 단추를 채워 보세요.', '작은 변화를 기록해 보세요.', '좋은 질문을 하나 더 해 보세요.', '마지막 확인을 잊지 마세요.', '주변의 도움을 받아 보세요.', '새로운 방법을 시험해 보세요.', '생각을 말이나 글로 표현해 보세요.', '중요한 일부터 정리해 보세요.', '잠깐 쉬며 방향을 살펴보세요.', '정한 목표를 마무리해 보세요.']
};

function getBirthdayFortune(year, month, day, categoryIndex) {
  const birthCode = `${String(year).padStart(4, '0')}${String(month).padStart(2, '0')}${String(day).padStart(2, '0')}`;
  const digits = birthCode.split('').map(Number);
  const offset = categoryIndex * 2;
  const tone = yearlyFortuneParts.tones[digits[offset % digits.length]];
  const strength = yearlyFortuneParts.strengths[digits[(offset + 3) % digits.length]];
  const rhythm = yearlyFortuneParts.rhythms[digits[(offset + 5) % digits.length]];
  const action = yearlyFortuneParts.actions[digits[(offset + 7) % digits.length]];
  return `${year}년 ${month}월 ${day}일생의 ${tone} 흐름이에요. ${strength}을 살려 ${rhythm} ${action}`;
}

function getYearFortuneCode(year, month, day, categoryIndex) {
  // 7919와 10000은 서로소이므로 같은 월·일·항목에서는 모든 4자리 연도가 서로 다른 코드를 갖는다.
  const value = (year * 7919 + month * 101 + day * 37 + categoryIndex * 1301) % 10000;
  return String(value).padStart(4, '0');
}

async function loadFestivalHoroscope() {
  try {
    const controller = new AbortController();
    const timeout = window.setTimeout(() => controller.abort(), 4500);
    const response = await fetch(firestoreDocumentUrl, { signal: controller.signal, cache: 'no-store' });
    window.clearTimeout(timeout);
    if (!response.ok) throw new Error(`Firestore ${response.status}`);
    const document = await response.json();
    const payload = document.fields?.payload?.stringValue;
    if (!payload) throw new Error('Firestore payload missing');
    const data = JSON.parse(payload);
    if (data.date !== festivalDate || !data.signs) throw new Error('Unexpected horoscope document');
    return { data, fromFirestore: true };
  } catch (error) {
    console.warn('Firestore 운세를 불러오지 못해 내장 데이터를 사용합니다.', error);
    return { data: festivalHoroscopeFallback, fromFirestore: false };
  }
}

function isBetween(month, day, sign) {
  const current = month * 100 + day;
  const start = sign.start[0] * 100 + sign.start[1];
  const end = sign.end[0] * 100 + sign.end[1];
  return start <= end ? current >= start && current <= end : current >= start || current <= end;
}

function findZodiac(month, day) { return zodiacSigns.find(sign => isBetween(month, day, sign)); }

function isValidCalendarDate(year, month, day) {
  const date = new Date(year, month - 1, day);
  return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day;
}

function dateLabel(year, month, day) { return `${year}년 ${month}월 ${day}일`; }

function parseBirthdayInput(value) {
  const normalized = value.trim();
  let match = normalized.match(/^(\d{4})\s*(?:년|[./-])\s*(\d{1,2})\s*(?:월|[./-])\s*(\d{1,2})\s*일?$/);
  if (!match) match = normalized.match(/^(\d{4})(\d{2})(\d{2})$/);
  if (!match) return null;
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  return isValidCalendarDate(year, month, day) ? { year, month, day } : null;
}

function setupEntryPage() {
  const form = document.querySelector('#birthday-form');
  if (!form) return;
  form.addEventListener('submit', event => {
    event.preventDefault();
    const input = document.querySelector('#birthday');
    const error = document.querySelector('#form-error');
    const birthday = parseBirthdayInput(input.value);
    if (!birthday) { error.textContent = '예: 2008년 10월 14일 또는 2008/10/14처럼 입력해 주세요.'; error.hidden = false; input.focus(); return; }
    error.hidden = true;
    const button = form.querySelector('button');
    button.disabled = true;
    document.body.classList.add('is-reading-stars');
    const encodedDate = `${birthday.year}-${String(birthday.month).padStart(2, '0')}-${String(birthday.day).padStart(2, '0')}`;
    window.setTimeout(() => { location.href = `result.html?birthday=${encodeURIComponent(encodedDate)}`; }, 1700);
  });
}

async function setupResultPage() {
  if (!document.querySelector('#result-card')) return;
  const params = new URLSearchParams(location.search);
  const match = (params.get('birthday') || '').match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) { location.replace('index.html'); return; }
  const year = Number(match[1]); const month = Number(match[2]); const day = Number(match[3]); const sign = findZodiac(month, day);
  if (!isValidCalendarDate(year, month, day) || !sign) { location.replace('index.html'); return; }
  document.title = `${sign.name} | 나의 별자리 찾기`;
  const imageFile = zodiacImageFiles[sign.key];
  document.querySelector('#constellation-art').innerHTML = `<img src="assets/zodiac-images/${imageFile}.png" alt="${sign.name} 실제 별 위치와 딥스카이 성도">`;
  document.querySelector('#date-display').textContent = `${dateLabel(year, month, day)}에 태어난 당신의 별자리`;
  document.querySelector('#zodiac-name').textContent = sign.name;
  document.querySelector('#zodiac-period').textContent = sign.period;
  document.querySelector('#zodiac-summary').textContent = sign.summary;
  document.querySelector('#zodiac-symbol').textContent = sign.symbol;
  document.querySelector('#zodiac-element').textContent = sign.element;
  document.querySelector('#zodiac-star').textContent = sign.star;
  document.querySelector('#fortune-title').textContent = '10월 14일의 별빛 운세';
  const list = document.querySelector('#fortune-list');
  list.setAttribute('aria-busy', 'true');
  list.innerHTML = '<p class="fortune-loading">별빛 운세 데이터를 불러오는 중...</p>';
  const { data, fromFirestore } = await loadFestivalHoroscope();
  const fortunes = data.signs[sign.key];
  if (!fortunes) { location.replace('index.html'); return; }
  list.innerHTML = '';
  list.removeAttribute('aria-busy');
  fortuneCategories.forEach(([field, category], index) => {
    const item = document.createElement('div');
    item.className = 'fortune-item';
    const heading = document.createElement('strong');
    heading.textContent = category;
    const copy = document.createElement('div');
    copy.className = 'fortune-copy';
    const message = document.createElement('span');
    message.textContent = `${fortunes[field]} ${getBirthdayFortune(year, month, day, index)}`;
    const code = document.createElement('small');
    code.className = 'fortune-code';
    code.textContent = `2026.10.14 기준 · 생년월일 고정 코드 ${getYearFortuneCode(year, month, day, index)}`;
    copy.append(message, code);
    item.append(heading, copy);
    list.append(item);
  });
  const source = document.querySelector('#fortune-source');
  source.textContent = fromFirestore
    ? 'Firestore 저장 데이터 · Powered by astroway.api'
    : '오프라인 예비 데이터 · Powered by astroway.api';
}

setupEntryPage();
setupResultPage();
