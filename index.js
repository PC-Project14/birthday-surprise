
const birthdayDate = "2026-10-30";

// Indian Standard Time (UTC+05:30)
const startTime = new Date(
  `${birthdayDate}T00:00:00+05:30`
).getTime() - 10 * 60 * 1000;

const expiryTime = new Date(
  `${birthdayDate}T23:59:59+05:30`
).getTime();

function checkBirthdayLink() {
  const now = Date.now();

  if (now < startTime) {
    document.body.innerHTML =
      "<h1>Your surprise isn't ready yet ✨</h1>";
  } else if (now > expiryTime) {
    document.body.innerHTML =
      "<h1>This birthday surprise has expired 💫</h1>";
  }
}

checkBirthdayLink();
