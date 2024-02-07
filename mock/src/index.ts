import { Elysia, t } from "elysia"

import forwarded_messages from "./data/forwarded_messages.json"
import groups from "./data/groups.json"
import messages from "./data/messages.json"
import users from "./data/users.json"

export const Res = {
  ok: <T>(data: T) => ({ status: "ok", data }),
  err: <T>(msg?: T) => ({ status: "failed", data: null, msg: msg ?? "not found" })
}

const okOrError = <T>(data: T) => (data ? Res.ok(data) : Res.err())

const app = new Elysia()
  .onRequest(({ request }) => {
    const url = new URL(request.url)
    console.log(`[${new Date().toLocaleString()}] ${request.method} ${url.pathname}${url.search}`)
  })
  .group("/bot", (app) =>
    app
      .get("/get_status", () => Res.ok({ online: Math.random() > 0.5 }))
      .get(
        "/get_stranger_info",
        ({ query: { user_id } }) => okOrError(users.find((it) => it.qid.toString() === user_id)),
        {
          query: t.Object({ user_id: t.String() })
        }
      )
      .get(
        "/get_group_info",
        ({ query: { group_id } }) => okOrError(groups.find((it) => it.gid.toString() === group_id)),
        {
          query: t.Object({ group_id: t.String() })
        }
      )
      .get(
        "/get_msg",
        ({ query: { message_id } }) => okOrError(messages[(parseInt(message_id) ?? 0) - 1]),
        {
          query: t.Object({ message_id: t.String() })
        }
      )
      .get(
        "/get_forward_msg",
        ({ query: { message_id } }) => {
          const messages = forwarded_messages[(parseInt(message_id) ?? 0) - 1]
          return okOrError(messages && { messages })
        },
        {
          query: t.Object({ message_id: t.String() })
        }
      )
      .post("/send_group_msg", () => Res.ok(null))
      .post("/set_essence_msg", () => Res.ok(null))
  )

app.listen(4321)

console.log(`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`)
