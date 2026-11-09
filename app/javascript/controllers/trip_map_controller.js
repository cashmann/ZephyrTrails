import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

// Shows a trip's start and end locations on an OpenStreetMap map.
export default class extends Controller {
  static values = { start: Object, end: Object }

  connect() {
    this.map = L.map(this.element, { scrollWheelZoom: false })

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    const start = this.addMarker(this.startValue, "Start", "#198754")
    const end = this.addMarker(this.endValue, "End", "#dc3545")

    this.map.fitBounds(L.latLngBounds([ start, end ]), { padding: [ 40, 40 ], maxZoom: 13 })
  }

  disconnect() {
    this.map?.remove()
  }

  addMarker({ lat, lng, label }, kind, color) {
    const latLng = L.latLng(lat, lng)
    const tooltip = document.createElement("span")
    tooltip.textContent = `${kind}: ${label}`

    L.circleMarker(latLng, { radius: 9, color: "#fff", weight: 2, fillColor: color, fillOpacity: 1 })
      .bindTooltip(tooltip)
      .addTo(this.map)

    return latLng
  }
}
