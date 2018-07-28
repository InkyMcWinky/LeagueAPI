//
//  MatchMethod.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 7/28/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

internal class MatchMethod: LeagueMethod {
    
    public enum MatchMethods {
        case ById(id: Double)
        case MatchesByAccountId(id: Double, beginTime: Double?, endTime: Double?, beginIndex: Int?, endIndex: Int?, championId: Int?, queue: Int?, season: Int?)
        case TimelineById(id: Double)
        case MatchIdsByTournamentCode(code: String)
        case ByIdAndTournamentCode(id: Double, code: String)
    }
    
    private var service: ServiceProxy
    private var method: MatchMethods
    
    public init(method: MatchMethods, region: Region) {
        self.method = method
        self.service = ServiceProxy(for: region)
    }
    
    func getAccessMethod() -> RESTRequester.AccessMethod {
        return .GET
    }
    
    func getMethodSignature() -> String {
        switch self.method {
        case .ById, .TimelineById:
            return "MatchAndTimelineById"
        case .MatchesByAccountId:
            return "MatchesByAccountId"
        case .MatchIdsByTournamentCode, .ByIdAndTournamentCode:
            return "Default"
        }
    }
    
    func getMethodUrl() -> String {
        let entrypoint: String = self.service.host
        let commonPath: String = "https://\(entrypoint)\(MethodPaths.Spectator.rawValue)/\(Version.RiotAPI)"
        switch self.method {
        case .ById(let id):
            return "\(commonPath)/matches/\(id)"
        case .MatchesByAccountId(let id, let beginTime, let endTime, let beginIndex, let endIndex, let championId, let queue, let season):
            var queryParameters: [String : Any] = [:]
            if let beginTime = beginTime { queryParameters["beginTime"] = beginTime }
            if let endTime = endTime { queryParameters["endTime"] = endTime }
            if let beginIndex = beginIndex { queryParameters["beginIndex"] = beginIndex }
            if let endIndex = endIndex { queryParameters["endIndex"] = endIndex }
            if let championId = championId { queryParameters["champion"] = championId }
            if let queue = queue { queryParameters["queue"] = queue }
            if let season = season { queryParameters["season"] = season }
            var queryParametersUrl: String = ""
            for parameter in queryParameters {
                queryParametersUrl += "\(queryParametersUrl == "" ? "" : "&")\(parameter.key)=\(parameter.value)"
            }
            return "\(commonPath)/matchlists/by-account/\(id)?\(queryParametersUrl)"
        case .TimelineById(let id):
            return "\(commonPath)/timelines/by-match/\(id)"
        case .MatchIdsByTournamentCode(let code):
            return "\(commonPath)/matches/by-tournament-code/\(code)/ids"
        case .ByIdAndTournamentCode(let id, let code):
            return "\(commonPath)/matches/\(id)/by-tournament-code/\(code)"
        }
    }
}
