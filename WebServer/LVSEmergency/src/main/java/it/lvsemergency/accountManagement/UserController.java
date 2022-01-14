package it.lvsemergency.accountManagement;

import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

@RestController
public class UserController {

	private UserService userService;
	
	@Autowired
	public UserController(UserService userService) {
		this.userService = userService;
	}
	
	private User dtoToEntity(UserDTO userDto) {
		var user = new User();
		user.setIdUser(userDto.getIdUser());
		user.setUsername(userDto.getUsername());
		user.setPassword(userDto.getPassword());
		return user;
	}
	
	@GetMapping(path = "/login")
	public UserDTO login() {
		return userService.userInformationResponse((UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
	}
	
	@PostMapping(path = "/modify")
	public User modifyUserInfo(@Valid @RequestBody UserDTO userDto) {
		return userService.modify(userDto);
	}
	
}
