# OS X Native wrapper for Google Chat
A very lightweight and simple Google Chat client that just opens the Chat web page in a native OS X window with a WebView.  Desktop notifications and Dock icon badging included.

# K.I.S.S.
Many apps of this sort are based on frameworks like Electron, which is all fine and good since disk space and memory are cheap, and hey you only have wait for it to load when you occasionally restart right?

For a targeted platform, it is often simpler to use the native capabilities like WebKit on OS X or IWebBrowser on Windows.  The resulting app is orders of magnitude smaller on disk and in memory.

# But...
One benefit of using Electron (and there aren't many, imho) for this sort of project is that since you're ultimately using Chrome to do the work, things are more likely to work with Google web sites.

And there's the problem.  This app used to work great... until Google made some change to chat, and now the chat page gets stuck on "Loading..."  It's probably some simple JavaScript issue, but I have not had time yet to figure it out.

# So, why?
I put this on github since it is fairly generic and could be used for wrapping any web site.  The code is super simple thanks to WebView, although ffs Apple you've deprecated that too?!?
