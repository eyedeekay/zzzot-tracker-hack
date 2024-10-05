window.addEventListener("load", function () {
  setupTags();
  function setupTags() {
    let els = document.querySelectorAll(".lvix1");
    for (let el of els)
      el.addEventListener("click", function () {
        let cl = el.classList[0];
        let divs = document.querySelectorAll("." + cl);
        for (let div of divs) div.style.display = hideDivs(div.style.display);
        showTags();
      });
    let divs = document.querySelectorAll(".lvix2");
    for (let div of divs) div.style.display = "none";
  }
  function showTags() {
    let els = document.querySelectorAll(".lvix1");
    for (let el of els) {
      el.style.display = "inline";
    }
  }
  function hideDivs(prev) {
    if (prev === "none") {
      return "inline";
    }
    return "none";
  }
});
