package it.lvsemergency.accountManagement;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

/**
 * Classe UserDetailsImpl.
 * Questa classe è necessaria per la gestione del metodo di autenticazione Basic Auth.
 * Per maggiori informazioni visitare il seguente link:
 * https://www.codejava.net/frameworks/spring-boot/spring-boot-security-authentication-with-jpa-hibernate-and-mysql
 */

@SuppressWarnings("serial")
public class UserDetailsImpl implements UserDetails {

	private String username;
	private String password;
	private List<GrantedAuthority> authorities;

	public UserDetailsImpl(User user) {
		this.username = user.getUsername();
		this.password = user.getPassword();

		this.authorities = Arrays.stream(user.getRole().toString().split(",")).map(SimpleGrantedAuthority::new)
				.collect(Collectors.toList());
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return authorities;
	}

	@Override
	public String getPassword() {
		return password;
	}

	@Override
	public String getUsername() {
		return username;
	}

	@Override
	public boolean isAccountNonExpired() {
		return true;
	}

	@Override
	public boolean isAccountNonLocked() {
		return true;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}
}