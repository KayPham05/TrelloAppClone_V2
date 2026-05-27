export async function fetchCurrentUserFromDB({
  getUsernameByUserUIdAPI,
  getBioByUserUIdAPI,
}) {
  try {
    const auth = JSON.parse(localStorage.getItem("user") || "{}");
    if (!auth?.userUId) return null;
    const [uRes, bRes] = await Promise.all([
      getUsernameByUserUIdAPI(auth.userUId),
      getBioByUserUIdAPI(auth.userUId),
    ]);
    const userName = uRes?.data?.userName ?? uRes?.data?.username ?? "";
    const bio = bRes?.data?.bio ?? "";
    return { userUId: auth.userUId, email: auth.email || "", userName, bio };
  } catch {
    return null;
  }
}