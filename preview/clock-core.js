/* 한글 글자 시계 6×6 판의 규칙. 미리보기(index.html)와 검사(node)가 함께 쓴다.
   D1: 1분 단위, 6×6 판. Chain Captain 화면 240×240 에 한 칸 40px.
   D2 (2026-11-26 사용자 요청 "아침, 저녁도 넣어줘"): 때를 아침 · 낮 · 저녁 · 밤 넷으로 나눈다.
     필요한 칸이 35칸이 되어 정각(2칸)과 입니다(3칸)를 뺐다. 0분에는 몇 시까지만 켜진다.
     남는 1칸에 정을 넣어 낮 12시 0분에 정오(정 + 십의 자리 오)를 켠다.
     비용: 정각 · 입니다 · 새벽을 쓸 수 없다.
     되돌리는 법: 7×7 판(한 칸 34px)으로 키우면 정각 · 입니다 · 새벽을 다시 넣을 수 있다.
       GRID 와 W 의 칸 번호만 바꾸면 되고, check() 가 새 판을 검사한다. */
(function (root) {
  const GRID = ['아침낮저녁밤', '열한두세네다', '여섯일곱덟아', '홉시정이삼사', '오십일이삼사', '오육칠팔구분'];
  const N = 6;
  const CELLS = GRID.join('').split('');
  // 칸 번호 = 줄 × 6 + 칸. 한 낱말의 칸은 읽는 차례(왼→오, 위→아래)로 놓인다.
  const W = {
    morning: [0, 1], day: [2], evening: [3, 4], night: [5],
    hour: { 1: [7], 2: [8], 3: [9], 4: [10], 5: [11, 13], 6: [12, 13], 7: [14, 15], 8: [12, 16], 9: [17, 18], 10: [6], 11: [6, 7], 12: [6, 8] },
    si: [19],
    noon: [20, 24],
    tens: { 2: [21], 3: [22], 4: [23], 5: [24] },
    sip: [25],
    unit: { 1: [26], 2: [27], 3: [28], 4: [29], 5: [30], 6: [31], 7: [32], 8: [33], 9: [34] },
    bun: [35]
  };
  // 때가 시작하는 시. 아침 < 낮 < 저녁 < 밤 이어야 한다. 밤은 다음 날 아침 전까지다.
  const DEF = { morning: 5, day: 11, evening: 18, night: 21, noon: true };
  const NAME = { morning: '아침', day: '낮', evening: '저녁', night: '밤' };
  function period(h, o) {
    if (h >= o.night || h < o.morning) return 'night';
    if (h >= o.evening) return 'evening';
    if (h >= o.day) return 'day';
    return 'morning';
  }

  // h: 0~23, m: 0~59. 켜지는 칸을 읽는 차례로 돌려준다. kind 는 색을 고르는 이름이다.
  function lit(h, m, opt) {
    const o = Object.assign({}, DEF, opt || {});
    const out = [];
    const add = (cells, kind) => cells.forEach(i => out.push({ i, kind }));
    if (o.noon && h === 12 && m === 0) { add(W.noon, 'noon'); return out; }
    const p = period(h, o);
    add(W[p], p);
    add(W.hour[h % 12 || 12], 'num');
    add(W.si, 'unit');
    if (m > 0) {
      const t = Math.floor(m / 10), u = m % 10;
      if (t >= 2) add(W.tens[t], 'num');
      if (t >= 1) add(W.sip, 'num');
      if (u) add(W.unit[u], 'num');
      add(W.bun, 'unit');
    }
    return out;
  }

  // 판과 따로 만든 문장. 검사에서 판이 만든 글자와 견준다.
  const HOUR_WORD = ['열두', '한', '두', '세', '네', '다섯', '여섯', '일곱', '여덟', '아홉', '열', '열한'];
  const DIG = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
  const sino = m => { const t = Math.floor(m / 10), u = m % 10; return (t >= 2 ? DIG[t] : '') + (t >= 1 ? '십' : '') + DIG[u]; };
  function sentence(h, m, opt) {
    const o = Object.assign({}, DEF, opt || {});
    if (o.noon && h === 12 && m === 0) return '정오';
    return NAME[period(h, o)] + ' ' + HOUR_WORD[h % 12] + ' 시' + (m > 0 ? ' ' + sino(m) + ' 분' : '');
  }

  // 하루 1,440분을 모두 돌며 두 가지를 본다.
  // 1) 켜지는 칸이 읽는 차례대로 놓였는가  2) 켜진 글자를 이으면 문장과 같은가
  function check(opt) {
    const bad = [];
    for (let h = 0; h < 24; h++) for (let m = 0; m < 60; m++) {
      const idx = lit(h, m, opt).map(c => c.i);
      const ordered = idx.every((v, k) => k === 0 || v > idx[k - 1]);
      const got = idx.map(i => CELLS[i]).join('');
      const want = sentence(h, m, opt).replace(/ /g, '');
      if (!ordered || got !== want) bad.push({ h, m, got, want, ordered });
    }
    return { total: 1440, bad };
  }

  const api = { GRID, N, CELLS, W, DEF, NAME, period, lit, sentence, check };
  root.HangulClock = api;
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
