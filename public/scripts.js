$(document).ready(function() {
  $.ajax({ url: "/refreshdata", cache: false });
  setTimeout(function() { window.location.reload(); }, 120000);
});
