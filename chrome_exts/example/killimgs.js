var imgs = document.getElementsByTagName("img");

for (var i = 0; i < imgs.length; i++) {
    var src = imgs[i].getAttribute("src");
    imgs[i].setAttribute("src", "#");
    imgs[i].setAttribute("_src", src);
}
