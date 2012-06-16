$(document).ready(function() {
  setInterval(function() { $.ajax({ url: "/refreshdata", cache: false }); }, 120000);
});

