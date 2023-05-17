//
//  Extensions.swift
//  archapp
//
//  Created by Krishna Kumar on 1/11/23.
//

import UIKit

protocol NavigationPresentation {
    func presentViewController(_ viewController: UIViewController, from fromViewController: UIViewController)
    func pushViewController(_ viewController: UIViewController, from navigationController: UINavigationController?)
    func dismissViewController(_ viewController: UIViewController)
    func popViewController(from navigationController: UINavigationController?)
    func dismissChildViewController(_ childViewController: UIViewController)
    func popToRootViewController(from navigationController: UINavigationController?)
}

struct NavigationPresenter: NavigationPresentation {
    func presentViewController(_ viewController: UIViewController, from fromViewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        fromViewController.present(viewController, animated: true, completion: nil)
    }

    func pushViewController(_ viewController: UIViewController, from navigationController: UINavigationController?) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func dismissViewController(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: {})
    }

    func popViewController(from navigationController: UINavigationController?) {
        navigationController?.popViewController(animated: true)
    }

    func dismissChildViewController(_ childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view?.removeFromSuperview()
        childViewController.removeFromParent()
    }

    func popToRootViewController(from navigationController: UINavigationController?) {
        navigationController?.popToRootViewController(animated: true)
    }
}
