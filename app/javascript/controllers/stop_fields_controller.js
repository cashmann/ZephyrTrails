import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "template", "insertionPoint" ]

  add() {
    const html = this.templateTarget.innerHTML.replaceAll("NEW_STOP", Date.now())
    this.insertionPointTarget.insertAdjacentHTML("beforebegin", html)

    this.insertionPointTarget.previousElementSibling.querySelector("input").focus()
  }

  remove(event) {
    event.currentTarget.closest(".stop-field").remove()
  }
}
