# ReactionProcessEditor

The Reaction Process Editor is a separate React project allowing to visually compose and edit the actual reaction processes.

The current version of the Reaction Process Editor is still privatley hosted on
https://github.com/cbuggle/eln-reaction-procedure-editor
Access on request to christian@buggle.net

The Reaction Process Editor uses the ELN as API backend.

As this is work in progress we will keep this code in a separate branch until at least the database schema is reasonably established.

## Setup

### Backend:

My developments can be found in the branch
`reaction-process-editor`

The backend is based on the Chemotion ELN editor on the most recent `main` (as of 2022-12-01). I try to keep it as up to date as possible.

It adds some ActiveRecord models, API access points, Grape Entity Serializing and last not least the definition of and an export to the generic KIT-ORD reaction database format.


For the proper functioning of the Frontend Editor
* The db seeds in `db/seeds/reaction_editor_seeds.rb` nned to run (included in a `rake db:seed` run).

* The Frontend Hostname needs to be set as ENV['HOSTNAME_REACTION_PROCESS_EDITOR'], e.g. `export HOSTNAME_REACTION_PROCESS_EDITOR="http://localhost:3000"`, preferably in your shell's profile (e.g. `.zshrc`) for the html link from an ELN reaction to its process editor.

### Frontend:
The frontend is a plain React yarn app to be installed and started with `yarn install`, `yarn start`.
It requires the hostname of the ELN backend to be set in `Constants.js`:

```
export const developmentBaseURL = "http://192.168.178.157:3000"
```
## Structure


### Data model

[note: `action` and `ReactionProcessAction` are used synonymously within this section]

The basic structure both in frontend and backend is:
Reaction <-1:1-> ReactionProcess <-1:n-> ReactionProcessStep <-1:n-> ReactionProcessAction>

The core of the reaction process data lies in the ReactionProcessAction. It has the relevant attributes:

* `action_name`: defines the type of the action, which can basically be any arbitrary string value describing the action. A set of are implemented  and used for the required funcionalities: "ADD", "REMOVE", "MOTION", "MOUNT", "PURIFY", "CONDITION", "TRANSFER".

* `starts_at`, `ends_at`, `duration`: The attributes for storing the timer of the action. In fact only "duration" is the relevant attribute for calculations but starts_at and ends_at are stored for consistency and user experience.

* `position`: The position (order) of the action within the associated reaction_process_step.

* `workup`: This is were most of the actual action data is stored. It is a hash to store the parameters of the action were (by convention). The stored data (parameter names) semantically "matches" the functionality provided by the respective action. (most of this as defined in the file "action_definitions_NJ.v2.xls" by N. Jung)


### API endpoints

The relevant API endpoints for ReactionProcess, ReactionProcessStep, ReactionProcessAction for the required behavior are mostly following REST / resource routing conventions.

The "source of truth" is the Database. All relevant changes will be persisted as soon as possible and all data will be refetched by the Editor after persisting and after even minor changes.

### Medium, Medium::MediumSamples, Medium::Additives, Medium::DiverseSolvent

Apart from the Samples defined and provided by a given Reaction, we need "Medium", "Additives" and "Diverse Solvents" that will be offered to the User in the SampleSelectBar and in the SampleSelect UI elements.

This is (currently) done in the DB-table "Medium" as STI for "Medium::MediumSample" (provided in UI Selects for adding media), "Medium::Additive" (displayed in the top right corner of the SampleBar) as they have very similiar data. (They might diverge in the future and if so we might to change ) (which might change).

### Vessels

For each ReactionProcess a set of vessels can be defined/created in the frontend.
Vessels are associated with a (only the current) ReactionProcess (which might be subject to change as Vessels might be required "globally".)

ReactionProcess <-1:n-> ReactionProcessVessels <-m:1->Vessel

Each ReactionProcessStep can be (optionally) assigned a vessel.


### Noteworthy in API

* The reaction data is initially fetched from the "get_eeaction_process" Endpoint, which will implicitly (and idempotently) create a ReactionProcess for the given reaction when non-existant.
* The ReactionProcess ´piggybacks the `additives`
* The ReactionProcessStep piggybacks `samples_options`, `added_samples_options`, `equipment_options`, `mounted_equipment_options`.

which are not part of the actual Reaction Process Data but required for UI Selects and as such conveniently transferred within a single request.


## Frontend

### Action Forms

The most important part of the Editor Frontend is `ActionForm.jsx`

It consists of two parts, the general and the action specific fields.
The general part has field "description".
The generic part is split up into (at time of writing) 9 sub-forms which are selected in ActionForm depending on the "action_name" of the action. => ActionForm.jsx is a good place to lookup which action_names are in use semantically (i.e.well-defined and have an existing form partial implemented), and each of the 9 sub_partial (actionForms/generic/*Form.jsx) is a good place to lookup which workup are used semantically.

#### Caveat
Most of the forms allow switching between different options (e.g. mount/unmount, samples/solvents/…)
Some of these switch between partials with inputs for differing workup.
E.g. The RemoveForm offers to remove "ADDITIVE" or "MEDIUM". ADDITIVE has inputs for parameters 'remove_temperature','remove_pressure', while MEDIUM has inputs 'remove_repetitions', 'duration_in_minutes'.

Due to the implementation as state attributes, when switching between the two Form options all the attributes will still be present in the state once an input has been set by the user. Subsequently they will be included in the state when persisting.

(E.g. the user sets "remove_temperature" to 25°, then decides to switch to "MEDIUM" instead. The remove_temperature will still be present in the state even though pointless for "MEDIUM")

While this unnecessary data does no actual harm (yet? It might be an issue once we export our data to other formats like e.g. ORD), it should be avoided to save trash data.

So currently the workup are sanitized in "ReactionProcessAction#fix_workup", where obsolete workup are deleted, depending on the action_name. Same is done for traces of "equipment_id" which might be present when the user switches "extra equipment" on and off again.

** ReactionProcessAction ** is sort of the wrong place. Probably sanitizing request parameters in ReactionProcessStepAPI might be better suited location.
Currently it is called before_validation, thus we need to take extra care not to accidently overwrite the existing attributes.
=> *This needs to be cleaned and might require some more work*

* As the Process Editor UI is undergoing a major rewrite (2022-12-01) this will be adressed accordingly in the near future.

### Frontend Data

The root frontend component of the Editor (i.e.. ReactionProcess data) is the ReactionProcessEditor.
It is included from APP.js with "reaction" as the only prop.

The ReactionProcessEditor stores the associated ReactionProcess as state,
and (re)fetches the ReactionProcess from the backend by it's id whenever relevant changes occur.
