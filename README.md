How to self-host your torrents en-masse with zzzot
==================================================

I2P is a great network for distributing information using Bittorrent.
However, it's not always easy to make your torrents discoverable to others.
Uploading files via a WebUI can be time-consuming when you wish to share hundreds of files.
It's easy to run an open tracker using zzzot, but open trackers don't maintain a searchable index of the files people are sharing.
This is a hack that will allow you to treat zzzot as both an open tracker **and** a searchable indexing tracker of files that you want to share.

 - `setup.sh` will do all this automatically on linux.

Step Zero: Install zzzot and script dependencies
------------------------------------------------

You need zzzot to make this work.
You can install zzzot by pasting this link `http://stats.i2p/i2p/plugins/zzzot.su3` into "Install from URL" on the [Plugin Config page](http://localhost:7657/configplugins).
You can also obtain zzzot from zzz's plugins page [inside of I2P](http://stats.i2p/i2p/plugins/).

Make a note of the zzzot tracker base32 address at [`http://127.0.0.1:7662`](http://127.0.0.1:7662).
Enter it into the environment variable `zzzot_announce` like so:

```sh
export zzzot_announce="thisisanexampleofafiftytwocharacterlongbasethirtytwo.b32.i2p"
```

You'll also need: `sed` `sort` `uniq` and `transmission-edit`.

Step One: Symlink your i2psnark downloads directory to zzzot's docroot
----------------------------------------------------------------------

After you install zzzot, symlink directory where I2PSnark stores it's downloads to a sub-directory of zzzot's document root.
If you're on Linux and used a `.jar` installer, this command will work:

```sh
ln -sf ~/.i2p/i2psnark ~/.i2p/plugins/zzzot/eepsite/docroot/i2psnark
```

Or, if you used a Debian package:

```sh
sudo -u i2psvc ln -sf /var/lib/i2p/i2p-config/i2psnark /var/lib/i2p/i2p-config/plugins/zzzot/eepsite/docroot/i2psnark
```

Step Two: Generate a new zzzot homepage
---------------------------------------

When you visit the zzzot plugin's homepage via a web browser, either locally or via I2P, it simply serves up the files found in the `eepsite/docroot`.
This allows you to customize the zzzot homepage in order to show whatever you want.
We're going to take advantage of this to generate an index of the torrents we're sharing along with some details about them.
To do this we'll use a shell script to generate the page.

```sh
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
        echo "  <div id="$filename" class=\"$tags\">"
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

generatePage
```

Step Three(Optional): Add the ability to filter torrents with Javascript
------------------------------------------------------------------------

If you're indexing hundreds of torrents, it will help to have the ability to filter the torrents based on their contents.
Our script from step two converts the titles of the torrents into a list of tags, which can then be filtered.
This provides us with a way of searching the available torrents efficiently.

```javascript
window.addEventListener("load", function() {
    setupTags();
    function setupTags() {
        let els = document.querySelectorAll(".lvix1");
        for (let el of els) el.addEventListener("click", function() {
            let cl = el.classList[0];
            console.log(cl);
            let divs = document.querySelectorAll("."+cl);
            for (let div of divs) div.style.display = hideDivs(div.style.display);
            showTags()
        })
    }
    function showTags() {
        let els = document.querySelectorAll(".lvix1");
        for (let el of els) {
            console.log("unhiding", el.classList)
            el.style.display = "inline";
        }
    }
    function hideDivs(prev) {
        if (prev === "none") {
            return "inline";
        }
        return "none"
    }
})
```
