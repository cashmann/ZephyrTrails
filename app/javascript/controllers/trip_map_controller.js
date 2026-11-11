import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

export default class extends Controller {
  static values = { stops: Array, legs: Array }

  connect() {
    this.map = L.map(this.element, { scrollWheelZoom: false })

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    const legs = this.legsValue.map((geometry) => this.addLeg(geometry))
    const stops = this.stopsValue.map((stop, index) => this.addStop(stop, index))

    const bounds = L.latLngBounds(stops)
    legs.forEach((leg) => bounds.extend(leg.getBounds()))

    this.map.fitBounds(bounds, { padding: [ 40, 40 ], maxZoom: 13 })
  }

  disconnect() {
    this.map?.remove()
  }

  addLeg(geometry) {
    const latLngs = geometry.map(([ lng, lat ]) => [ lat, lng ])

    return L.polyline(latLngs, { color: "#0d6efd", weight: 4, opacity: 0.8 }).addTo(this.map)
  }

  addStop({ lat, lng, label }, index) {
    const latLng = L.latLng(lat, lng)
    const tooltip = document.createElement("span")
    tooltip.textContent = `${this.stopName(index)}: ${label}`

    L.circleMarker(latLng, { radius: 9, color: "#fff", weight: 2, fillColor: this.stopColor(index), fillOpacity: 1 })
      .bindTooltip(tooltip)
      .addTo(this.map)

    return latLng
  }

  stopName(index) {
    if (this.isStart(index)) return "Start"
    if (this.isEnd(index)) return "End"

    return `Stop ${index + 1}`
  }

  stopColor(index) {
    if (this.isStart(index)) return "#198754"
    if (this.isEnd(index)) return "#dc3545"

    return "#0d6efd"
  }

  isStart(index) {
    return index === 0
  }

  isEnd(index) {
    return index === this.stopsValue.length - 1
  }
}
