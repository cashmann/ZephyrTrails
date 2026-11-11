import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

export default class extends Controller {
  static values = { start: Object, end: Object, route: Array }

  connect() {
    this.map = L.map(this.element, { scrollWheelZoom: false })

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    const route = L.polyline(this.routeValue.map(([ lng, lat ]) => [ lat, lng ]), { color: "#0d6efd", weight: 4, opacity: 0.8 })
      .addTo(this.map)

    const start = this.addMarker(this.startValue, "Start", "#198754")
    const end = this.addMarker(this.endValue, "End", "#dc3545")

    this.map.fitBounds(route.getBounds().extend(start).extend(end), { padding: [ 40, 40 ], maxZoom: 13 })
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
