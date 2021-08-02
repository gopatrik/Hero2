import UIKit

public protocol TransitionProvider: UIViewController {
  var transition: Transition? { get }
}

public class TransitionCoordinator: NSObject {
  public static let shared = TransitionCoordinator()

  public var defaultTransition: Transition = HeroTransition()
  public private(set) var currentTransition: Transition?

  private func setupTransition(from: UIViewController, to: UIViewController, isPresenting: Bool, isNavigationTransition: Bool) {
    let transition = ((isPresenting ? to : from) as? TransitionProvider)?.transition ?? defaultTransition
    self.transition = transition
    transition.setupTransition(isPresenting: isPresenting, isNavigationTransition: isNavigationTransition)
  }
}

extension TransitionCoordinator: UIViewControllerTransitioningDelegate {
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    transition as? UIViewControllerInteractiveTransitioning
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    setupTransition(from: presenting, to: presented, isPresenting: true, isNavigationTransition: false)
    return transition
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard let toVC = dismissed.presentingViewController else { return nil }
    setupTransition(from: dismissed, to: toVC, isPresenting: false, isNavigationTransition: false)
    return transition
  }

  public func interactionControllerForDismissal(using _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    interactiveTransitioning
  }

  public func interactionControllerForPresentation(using _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    interactiveTransitioning
  }
}

extension TransitionCoordinator: UINavigationControllerDelegate {
  public func navigationController(_: UINavigationController, interactionControllerFor _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    interactiveTransitioning
  }

  public func navigationController(_: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from: UIViewController, to: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    setupTransition(from: from, to: to, isPresenting: operation == .push, isNavigationTransition: true)
    return transition
  }
}