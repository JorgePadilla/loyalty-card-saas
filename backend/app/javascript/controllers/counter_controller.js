import { Controller } from "@hotwired/stimulus"

// Smooth number counter animation for dashboard stats
export default class extends Controller {
  static values = { target: Number, duration: { type: Number, default: 800 } }

  connect() {
    this.animate()
  }

  targetValueChanged() {
    this.animate()
  }

  animate() {
    const target = this.targetValue
    const duration = this.durationValue
    const start = parseInt(this.element.textContent.replace(/,/g, "")) || 0
    const startTime = performance.now()

    const step = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const eased = 1 - Math.pow(1 - progress, 3) // ease-out cubic
      const current = Math.round(start + (target - start) * eased)
      this.element.textContent = current.toLocaleString()

      if (progress < 1) {
        requestAnimationFrame(step)
      }
    }

    requestAnimationFrame(step)
  }
}
