# SnowblindDemo

Step to run this demo

1 add SAP iOS SDK framework(Debug-iphonesimulator) into Framework folder in SAPMDC project, make sure select checkbox(Copy items if needed)

2 build SAPMDC.framework 

3 add SAP iOS SDK framework(Debug-iphonesimulator) into SnowblindDemo project, make sure select checkbox(Copy items if needed）

4 select project targets, General -> Embedded Binaries, add iOS SDK framework

5 then build SnowblindDemo


SnowblindFramework -- copy from SAPMDC, some changes has already made for this demo.

    1 create method in ODataServiceProvider.swift
    Line 485: add X-SMP-APPID and AccessToken for pass parameters
    if let APPID = params["X-SMP-APPID"] as? String {
        provider.httpHeaders.setHeader(withName: "X-SMP-APPID", value: APPID)
    }
    if let token = params["AccessToken"] as? String {
        provider.httpHeaders.setHeader(withName: "Authorization", value: "Bearer \(token)")
    }
    Line 502:  comment for no need get token
    //try onlineService?.acquireToken()

    2 SectionDelegate.h expose 2 methods for delegate to getData and event handler
        - (NSDictionary *)getBoundData: (NSNumber*) row;
        - (void)loadMoreItems: (NSNumber*) row;

    3 getBoundData method in Sections.swift, add : for pass parameter row for delegate
    func getBoundData(row: Int) -> NSDictionary? {
        return self.callback.perform(NSSelectorFromString("getBoundData:"), with: row as NSNumber!)?.takeUnretainedValue()          as? NSDictionary
    }
