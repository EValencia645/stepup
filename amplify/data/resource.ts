import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

const schema = a.schema({
  StepRecord: a
    .model({
      userName: a.string().required(),
      stepCount: a.integer().required(),
      date: a.date().required(),
      notes: a.string(),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.authenticated().to(['read']),
    ]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
  },
});