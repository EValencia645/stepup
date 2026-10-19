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

  Team: a
    .model({
      name: a.string().required(),
      code: a.string().required(),   // short join code e.g. "STEP42"
      createdBy: a.string().required(),
      startDate: a.date().required(),
      endDate: a.date().required(),
      goalSteps: a.integer(),        // optional team step goal
    })
    .authorization((allow) => [
      allow.owner(),
      allow.authenticated().to(['read']),
    ]),

  TeamMember: a
    .model({
      teamId: a.string().required(),
      userName: a.string().required(),
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
