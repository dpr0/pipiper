import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "@fortawesome/fontawesome-free/js/all";

Rails.start()
ActiveStorage.start()

require("jquery")
require("@nathanvda/cocoon")
import 'bootstrap'
import './stylesheets/application'
