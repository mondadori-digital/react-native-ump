# react-native-ump

A React Native component for Google User Messaging Platform SDK ([Funding Choices](https://support.google.com/fundingchoices/))

## Getting started

**npm:**
`$ npm install react-native-ump --save`

**Yarn:**
`$ yarn add react-native-ump`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ump` and add `RNUmp.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNUmp.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import it.mondadori.RNUmpPackage;` to the imports at the top of the file
- Add `new RNUmpPackage()` to the list returned by the `getPackages()` method

2. Append the following lines to `android/settings.gradle`:
   ```
   include ':react-native-ump'
   project(':react-native-ump').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ump/android')
   ```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
   ```
     compile project(':react-native-ump')
   ```

## Usage

```javascript
import RNUmp from 'react-native-ump';

// TODO: What to do with the module?
RNUmp;
```
