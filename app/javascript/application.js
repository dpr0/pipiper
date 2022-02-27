import "@hotwired/turbo-rails"
import "./controllers"
import jquery from "jquery"
import "jquery-ui"
import "cocoon-js";

window.jQuery = jquery
window.$ = jquery

$("tr[data-link]").click(function () { window.location = $(this).data("link") })
