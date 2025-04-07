enum ViewStateEnum<T> {
    case idle
    case loading
    case loaded(T)
    case error(NetworkError)
}
