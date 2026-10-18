"use strict";
/* Nút hỗ trợ cho bản OFFLINE: Tăng cấp + Nhận vàng (không tốn tiền/đồ).
   - Chỉ hoạt động khi KHÔNG đăng nhập tài khoản online (tránh ảnh hưởng xếp hạng / chợ / thư).
   - Chỉnh số lượng ở 2 hằng số bên dưới. */
(function () {
  var GOLD_PER_TAP = 1000000; // vàng (ngân lượng) mỗi lần bấm
  var LV_BIG = 10;            // số cấp của nút "+10"

  function online() { return typeof NET !== "undefined" && NET && NET.user; }
  function ready() { return typeof S !== "undefined" && S && S.fac; }

  function levelUp(n) {
    if (!ready()) return;
    if (online()) { toast("Đang đăng nhập online: nút bị khóa"); return; }
    var cap = levelCap(), gained = 0;
    while (gained < n && S.lvl < cap) {
      S.lvl++; S.xp = 0;
      S.attrPts += PTS_PER_LEVEL;
      S.skPts += SKILL_PTS_PER_LEVEL;
      gained++;
      R.dirty = true;
      if (typeof onLevelUp === "function") onLevelUp();
    }
    if (!gained) { toast("Đã đạt cấp tối đa (" + cap + ")"); return; }
    uiSfx("levelup");
    log('<b class="up">Lên cấp ' + S.lvl + '!</b> (+' + gained + ' cấp)');
    toast("Cấp " + S.lvl);
    if (typeof refresh === "function") refresh();
    save();
  }

  function addGold() {
    if (!ready()) return;
    if (online()) { toast("Đang đăng nhập online: nút bị khóa"); return; }
    S.gold += GOLD_PER_TAP;
    uiSfx("click");
    toast("+" + fmtL(GOLD_PER_TAP) + " ngân lượng");
    save();
  }

  function mount() {
    if (document.getElementById("cheatBox")) return;
    var app = document.getElementById("app");
    if (!app) return;
    var st = document.createElement("style");
    st.textContent =
      "#cheatBox{position:absolute;left:6px;top:42%;z-index:5;display:flex;flex-direction:column;gap:6px;opacity:.7}" +
      "#cheatBox button{width:38px;height:38px;border-radius:50%;border:1px solid #c8a24a;" +
      "background:radial-gradient(#3a2f1c,#120d06);color:#ffd24a;font-size:13px;font-weight:700;padding:0;line-height:1}" +
      "#cheatBox button:active{transform:scale(.92)}" +
      "#cheatBox #cTog{width:26px;height:26px;font-size:12px;opacity:.6;align-self:flex-start}" +
      "#cheatBox.hide .cb{display:none}";
    document.head.appendChild(st);
    var box = document.createElement("div");
    box.id = "cheatBox";
    box.innerHTML =
      '<button id="cTog" title="Ẩn / hiện nút">⚙</button>' +
      '<button class="cb" id="cLv" title="Tăng 1 cấp">Lv+</button>' +
      '<button class="cb" id="cLv10" title="Tăng ' + LV_BIG + ' cấp">+' + LV_BIG + '</button>' +
      '<button class="cb" id="cGold" title="Nhận vàng miễn phí">💰</button>';
    app.appendChild(box);
    document.getElementById("cLv").onclick = function () { levelUp(1); };
    document.getElementById("cLv10").onclick = function () { levelUp(LV_BIG); };
    document.getElementById("cGold").onclick = addGold;
    var KEY = "jx_cheat_hide";
    try { if (localStorage.getItem(KEY) === "1") box.classList.add("hide"); } catch (e) {}
    document.getElementById("cTog").onclick = function () {
      var h = box.classList.toggle("hide");
      try { localStorage.setItem(KEY, h ? "1" : "0"); } catch (e) {}
    };
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", mount);
  else mount();
})();
