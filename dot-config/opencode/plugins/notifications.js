/**
 * Desktop notifications for OpenCode events that require human attention.
 * Requires: brew install terminal-notifier
 *
 * Events handled:
 *   question.asked    - AI is asking a structured question
 *   permission.asked  - AI needs permission to use a tool
 *   session.idle      - Session finished a turn, awaiting input
 *   session.error     - Session encountered an error
 */
export const NotificationsPlugin = async ({ $, directory }) => {
  const getContext = async () => {
    const repoName = directory.split("/").pop() || "unknown"
    try {
      const branch = (
        await $`git -C ${directory} rev-parse --abbrev-ref HEAD`
          .nothrow()
          .text()
      ).trim()
      return branch ? `${repoName}:${branch}` : `${repoName}:(no branch)`
    } catch {
      return `${repoName}:(no git)`
    }
  }

  const notify = async (title, message) => {
    await $`terminal-notifier -title ${title} -message ${message} -group opencode -sound default -ignoreDnD`
      .quiet()
      .nothrow()
  }

  return {
    event: async ({ event }) => {
      if (event.type === "question.asked") {
        const context = await getContext()
        const first = event.properties.questions[0]
        const detail = first?.question || first?.header || "Question"
        await notify("OpenCode - Question", `[${context}] ${detail}`)
      } else if (event.type === "permission.asked") {
        const context = await getContext()
        const { permission, patterns } = event.properties
        const detail =
          patterns?.length
            ? `${permission}: ${patterns.join(", ")}`
            : permission
        await notify("OpenCode - Permission Required", `[${context}] ${detail}`)
      } else if (event.type === "session.idle") {
        const context = await getContext()
        await notify("OpenCode - Awaiting Input", context)
      } else if (event.type === "session.error") {
        const context = await getContext()
        const err = event.properties.error
        const detail = err
          ? `${err.name}: ${"message" in err.data ? err.data.message : err.name}`
          : "Unknown error"
        await notify("OpenCode - Error", `[${context}] ${detail}`)
      }
    },
  }
}
