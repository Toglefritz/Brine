# Brine_Cloud_Functions

## To emulate functions:

Run firebase emulators:start and check the output for the URL of the Emulator Suite UI. It defaults to localhost:4000, but may be hosted on a different port on your machine. Enter that URL in your browser to open the Emulator Suite UI.

Check the output of the firebase emulators:start command for the URL of the HTTP function. It will look similar to http://localhost:5001/MY_PROJECT/us-central1/FUNCTION_NAME, except that:

MY_PROJECT will be replaced with your project ID.
FUNCTION_NAME will be replaced with your function name.
The port may be different on your local machine.
Add query strings to the end of the function's URL as needed by the function. This should look something like: http://localhost:5001/MY_PROJECT/us-central1/FUNCTION_NAME?query=info.

Create a new message by opening the URL in a new tab in your browser.

View the effects of the functions in the Emulator Suite UI:

In the Logs tab, you should see new logs indicating that the function ran.
