# Vimeo Browser

Final project for Udacity Nano-degree

## Notes on running the application

In order to connect to the Vimeo API, you require access keys which can be obtained via the website: https://developer.vimeo.com.

For project review by Udacity, Credentials will be provided.

## How the app works

On initial luanch the application should check to see if there are any categories in the Core Data DB. If there aren't any, it will fetch them.

Once we have category information, the app will loop through each category and pull the latest videos, whilst this is happening the system network indicator should display and you should see videos being presented in the Most Recent table.

When you select a video from one of the tables, it should segue to the video view page, which shows a webview and some basic information about the video. From here you have the option to add/remove the video from your bookmarks. Adding/removing bookmarks should instantly take effect in the favourties table.

The app is designed to work purely in portrait mode, when watching a video in fullscreen you can rotate the device for better viewing.

## Future Enhancements

* Custom designed UI
* Paging view controller for navigating videos
* View user information and follow
* Favourite categories
* Background Fetch
* Airplay Support - should be able to do this already
* Search facility
* Native video rather than webview (depends on API)
* Infinite Scroll

