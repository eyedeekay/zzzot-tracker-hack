#! /usr/bin/env sh

tagList() {
    echo "  <div class=\"tags\">Tags:"
    for torrent in i2psnark/*.torrent; do
        filename=$(echo $torrent | sed 's|.torrent||g')
        title=$(echo $filename | sed 's|-| |g' | sed 's|i2psnark/||g')
        tags=$(echo $title | sed 's|\.| |g' | sed 's|@| |g')
        for tag in $tags; do
            for tag in $tags; do
                echo "    <a class=\"$tag lvix1\" href=\"#$tag\">$tag</a>"
            done
        done
    done
    echo "  </div>"
}

generatePage() {
    echo "<!doctype html>"
    echo "<html lang=en>"
    echo "<head>"
    echo "<meta charset=utf-8>"
    echo "<title>Torrent Index</title>"
    echo "<script src=\"script.js\"></script>"
    echo "<style>"
    echo "div {"
    echo "  display: \"inline\";"
    echo "}"
    echo "</style>"
    echo "</head>"
    echo "<body>"
    cd "$SHARE"
    tagList | sort -u
    for torrent in i2psnark/*.torrent; do
        transmission-edit -a "http://$zzzot_announce/a" "$torrent"
        filename=$(echo $torrent | sed 's|.torrent||g')
        title=$(echo $filename | sed 's|-| |g' | sed 's|i2psnark/||g')
        tags=$(echo $title | sed 's|\.| |g' | sed 's|@| |g')
        echo "  <div id="$filename" class=\"lvix2 $tags\">"
        echo "    <a href=\"$torrent\">$title</a></br>"
        echo "    <div class=\"tags\">Tags:"
        for tag in $tags; do
            echo "<a class=\"$tag lvix1\" href=\"#$tag\">$tag</a>"
        done
        echo "    </div>"
        echo "  </div>"
    done
    cd $BACK
    echo "</body>"
    echo "</html>"
}

script(){
    echo 'window.addEventListener("load", function () {
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
'
}

if [ ! -f script.js ]; then
    script | tee script.js
fi

if [ $(whoami) = "i2psvc" ]; then
    if [ ! -d /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot ]; then
        echo "zzzot directory does not exist, did you read the instructions?"
        exit 1
    fi
    if [ ! -d /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/i2psnark ]; then
        echo "symlinking snark dir"
        ln -sf /var/lib/i2p/i2p-config/i2psnark /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/i2psnark
    fi
    export BACK=$(pwd)
    export SHARE=/var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/
    generatePage | tee /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/index.html
    cp -v script.js /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/script.js
else
    if [ ! -d "$HOME/.i2p/plugins/zzzot/eepsite/docroot" ]; then
        echo "zzzot directory does not exist, did you read the instructions?"
        exit 1
    fi
    if [ -d "$HOME/.i2p/i2psnark" ]; then
        if [ ! -d "$HOME/.i2p/plugins/zzzot/eepsite/docroot/i2psnark" ]; then
            echo "symlinking snark dir"
            ln -sf "$HOME/.i2p/i2psnark" "$HOME/.i2p/plugins/zzzot/eepsite/docroot/i2psnark"
        fi
        export BACK=$(pwd)
        export SHARE="$HOME/.i2p/plugins/zzzot/eepsite/docroot/"
        generatePage | tee "$HOME/.i2p/plugins/zzzot/eepsite/docroot/index.html"
        cp -v script.js "$HOME/.i2p/plugins/zzzot/eepsite/docroot/script.js"
    else
        echo "i2psnark directory does not exist, did you install I2P using a \`.deb\`?"
        exit 1
    fi
fi