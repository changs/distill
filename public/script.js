// Page-by-page navigation for Kindle - keyboard only to avoid refresh
document.addEventListener('DOMContentLoaded', function() {
  // Only handle keyboard navigation, which users can control
  // Click navigation removed because it causes e-ink refresh

  document.addEventListener('keydown', function(e) {
    const pageHeight = window.innerHeight * 0.75;

    // Space or Right arrow for next page
    if (e.key === ' ' || e.key === 'ArrowRight' || e.key === 'PageDown') {
      e.preventDefault();
      window.scrollBy(0, pageHeight);
    }
    // Left arrow or PageUp for previous page
    else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      window.scrollBy(0, -pageHeight);
    }
  });
});
