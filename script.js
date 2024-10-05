window.addEventListener("load", function () {
  setupTags();
  function setupTags() {
    let els = document.querySelectorAll(".lvix1");
    for (let el of els)
      el.addEventListener("click", function () {
        let divset = document.querySelectorAll(".lvix2");
        for (let div of divset) div.style.display = "none";
        let cl = el.classList[0];
        let divs = document.querySelectorAll("." + cl);
        for (let div of divs) div.style.display = "inline";
        showTags();
      });
  }
  function showTags() {
    let els = document.querySelectorAll(".lvix1");
    for (let el of els) {
      el.style.display = "inline";
    }
  }
});
