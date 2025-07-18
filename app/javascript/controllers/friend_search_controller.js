import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchInput", "searchResults"];

  connect() {
    console.log("Friend search controller connected");
  }

  search(event) {
    // Clear previous timeout
    clearTimeout(this.searchTimeout);

    // Set a new timeout to avoid too many requests
    this.searchTimeout = setTimeout(() => {
      const searchTerm = this.searchInputTarget.value.trim();

      if (searchTerm.length >= 3) {
        // You can add AJAX search here if needed
        console.log("Searching for:", searchTerm);
      }
    }, 300);
  }
}
