import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { index: { type: Number, default: 0 } }

  connect() {
    this.showTab(this.indexValue)
  }

  switch(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("border-matte", i === index)
      tab.classList.toggle("text-matte", i === index)
      tab.classList.toggle("border-transparent", i !== index)
      tab.classList.toggle("text-secondary", i !== index)
    })
    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }
}
