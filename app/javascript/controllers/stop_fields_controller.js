import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "template", "insertionPoint", "addButton" ]
  static values = { max: Number }

  connect() {
    this.updateAddButton()
  }

  add() {
    const html = this.templateTarget.innerHTML.replaceAll("NEW_STOP", Date.now())
    this.insertionPointTarget.insertAdjacentHTML("beforebegin", html)

    this.insertionPointTarget.previousElementSibling.querySelector("input").focus()
    this.updateAddButton()
  }

  remove(event) {
    event.currentTarget.closest(".stop-field").remove()
    this.updateAddButton()
  }

  updateAddButton() {
    this.addButtonTarget.disabled = this.stopCount >= this.maxValue
  }

  get stopCount() {
    return this.element.querySelectorAll(":scope > .stop-field").length
  }
}
